#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="${ECS_EFS_MOUNTER_CONFIG:-/etc/ecs/efs-mounts.json}"
REQUIRED="${ECS_EFS_MOUNTER_REQUIRED:-false}"
LOGGER_TAG="ecs-efs-mounter"

log() {
    local message="$1"
    printf '%s\n' "${message}"
    if command -v logger >/dev/null 2>&1; then
        logger -t "${LOGGER_TAG}" "${message}"
    fi
}

fail() {
    log "ERROR: $1"
    exit 1
}

require_dependencies() {
    local command_name
    for command_name in findmnt jq mount mountpoint umount; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            fail "Required command is not available: ${command_name}"
        fi
    done
}

validate_config() {
    if [[ "${REQUIRED}" != "true" && "${REQUIRED}" != "false" ]]; then
        fail "ECS_EFS_MOUNTER_REQUIRED must be true or false"
    fi
    if [[ ! -f "${CONFIG_PATH}" ]]; then
        if [[ "${REQUIRED}" == "true" ]]; then
            fail "Required EFS mount configuration is missing: ${CONFIG_PATH}"
        fi
        log "No EFS mount configuration at ${CONFIG_PATH}; no mounts requested."
        return 0
    fi

    require_dependencies

    if ! jq -e '
        def valid_mount_path:
            type == "string"
            and test("^/mnt/[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$")
            and (contains("..") | not);
        def valid_optional_id($pattern):
            . == null or (type == "string" and test($pattern));
        type == "object"
        and .version == 1
        and (.mounts | type == "array")
        and ([((.mounts // [])[] | .name)] | length == (unique | length))
        and ([((.mounts // [])[] | .mountPath)] | length == (unique | length))
        and all(.mounts[];
            type == "object"
            and (.name | type == "string" and test("^[A-Za-z0-9_.-]+$"))
            and (.fileSystemId | type == "string" and test("^fs-[0-9a-f]+$"))
            and (.mountPath | valid_mount_path)
            and ((.accessPointId // null) | valid_optional_id("^fsap-[0-9a-f]+$"))
            and (.readOnly == null or (.readOnly | type == "boolean"))
            and (.tls == null or (.tls | type == "boolean"))
            and (.iam == null or (.iam | type == "boolean"))
        )
    ' "${CONFIG_PATH}" >/dev/null; then
        fail "Invalid EFS mount configuration: ${CONFIG_PATH}"
    fi
}

mount_one() {
    local name="$1"
    local file_system_id="$2"
    local access_point_id="$3"
    local mount_path="$4"
    local read_only="$5"
    local tls="$6"
    local iam="$7"
    local file_system_type
    local mount_options=()
    local mount_option_string
    local mount_command=(mount -t efs)

    mkdir -p "${mount_path}"

    if mountpoint -q "${mount_path}"; then
        file_system_type=$(findmnt -rn -T "${mount_path}" -o FSTYPE || true)
        if [[ "${file_system_type}" != "efs" && "${file_system_type}" != "nfs4" ]]; then
            fail "Mount path ${mount_path} is already mounted with type ${file_system_type}"
        fi
        log "EFS resource ${name} is already mounted at ${mount_path}."
        return 0
    fi

    if [[ "${tls}" == "true" ]]; then
        mount_options+=(tls)
    fi
    if [[ "${iam}" == "true" ]]; then
        mount_options+=(iam)
    fi
    if [[ "${read_only}" == "true" ]]; then
        mount_options+=(ro)
    fi
    if [[ -n "${access_point_id}" && "${access_point_id}" != "__none__" ]]; then
        mount_options+=("accesspoint=${access_point_id}")
    fi

    if ((${#mount_options[@]} > 0)); then
        mount_option_string=$(IFS=,; printf '%s' "${mount_options[*]}")
        mount_command+=(-o "${mount_option_string}")
    fi

    log "Mounting EFS resource ${name} at ${mount_path}."
    if ! "${mount_command[@]}" "${file_system_id}:/" "${mount_path}"; then
        fail "Unable to mount EFS resource ${name} at ${mount_path}"
    fi

    if ! mountpoint -q "${mount_path}"; then
        fail "EFS mount did not create a mount at ${mount_path}"
    fi
    log "EFS resource ${name} is ready at ${mount_path}."
}

mount_resources() {
    validate_config
    if [[ ! -f "${CONFIG_PATH}" ]]; then
        return 0
    fi

    while IFS=$'\t' read -r name file_system_id access_point_id mount_path read_only tls iam; do
        mount_one \
            "${name}" \
            "${file_system_id}" \
            "${access_point_id}" \
            "${mount_path}" \
            "${read_only}" \
            "${tls}" \
            "${iam}"
    done < <(
        jq -r '
            .mounts[]
            | [
                .name,
                .fileSystemId,
                (.accessPointId // "__none__"),
                .mountPath,
                (if (.readOnly // true) then "true" else "false" end),
                (if (.tls // true) then "true" else "false" end),
                (if (.iam // true) then "true" else "false" end)
              ]
            | @tsv
        ' "${CONFIG_PATH}"
    )
}

unmount_resources() {
    if [[ ! -f "${CONFIG_PATH}" ]]; then
        log "No EFS mount configuration at ${CONFIG_PATH}; no mounts requested."
        return 0
    fi

    require_dependencies
    validate_config
    while IFS= read -r mount_path; do
        if mountpoint -q "${mount_path}"; then
            log "Unmounting EFS resource at ${mount_path}."
            umount "${mount_path}"
        fi
    done < <(jq -r '.mounts | reverse[] | .mountPath' "${CONFIG_PATH}")
}

case "${1:-mount}" in
    mount)
        mount_resources
        ;;
    unmount)
        unmount_resources
        ;;
    validate)
        validate_config
        ;;
    *)
        printf 'Usage: %s {mount|unmount|validate}\n' "$0" >&2
        exit 2
        ;;
esac
