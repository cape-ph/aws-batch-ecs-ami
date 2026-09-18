REGION ?= us-east-2

.PHONY: check-packer
check-packer:
	@packer_path="$$(command -v packer || true)"; \
	if [ -z "$$packer_path" ]; then \
		echo 'ERROR: HashiCorp Packer could not be found. Make sure the mise-managed Packer is in PATH'; \
		exit 1; \
	fi; \
	if ! packer version 2>/dev/null | grep -q '^Packer v'; then \
		echo "ERROR: $$packer_path is not HashiCorp Packer. Use the mise-managed Packer for this repository"; \
		exit 1; \
	fi

.PHONY: init
init: check-packer
	packer init .

.PHONY: check-region
check-region:
	@bash -c "if [ -z ${REGION} ]; then echo 'ERROR: REGION variable must be set. Example: \"REGION=us-west-2 make al2\"'; exit 1; fi"

%.pkrvars.hcl:
	echo "Missing configuration file: ${@}."
	exit 1

.PHONY: validate
validate: check-region init
	packer validate -var "region=${REGION}" .

.PHONY: build
build: check-region init validate-al2023 release.auto.pkrvars.hcl
	packer build -only="amazon-ebs.al2023" -var "region=${REGION}" .

.PHONY: validate-awsbatch
validate-awsbatch: check-region init awsbatch.pkrvars.hcl
	packer validate -var "region=${REGION}" --var-file="awsbatch.pkrvars.hcl" .

.PHONY: build-awsbatch
build-awsbatch: check-region init validate release.auto.pkrvars.hcl awsbatch.pkrvars.hcl
	packer build -only="amazon-ebs.al2023" -var "region=${REGION}" --var-file="awsbatch.pkrvars.hcl" .

.PHONY: validate-nextflow
validate-nextflow: check-region init nextflow.pkrvars.hcl
	packer validate -var "region=${REGION}" --var-file="nextflow.pkrvars.hcl" .

.PHONY: build-nextflow
build-nextflow: check-region init validate release.auto.pkrvars.hcl nextflow.pkrvars.hcl
	packer build -only="amazon-ebs.al2023" -var "region=${REGION}" --var-file="nextflow.pkrvars.hcl" .

.PHONY: validate-nextflow-kraken2
validate-nextflow-kraken2: check-region init nextflow-kraken2.pkrvars.hcl
	packer validate -var "region=${REGION}" --var-file="nextflow-kraken2.pkrvars.hcl" .

.PHONY: build-nextflow-kraken2
build-nextflow-kraken2: check-region init validate release.auto.pkrvars.hcl nextflow-kraken2.pkrvars.hcl
	packer build -only="amazon-ebs.al2023" -var "region=${REGION}" --var-file="nextflow-kraken2.pkrvars.hcl" .

.PHONY: validate-jupyterhub
validate-jupyterhub: check-region init jupyterhub.pkrvars.hcl
	packer validate -var "region=${REGION}" --var-file="jupyterhub.pkrvars.hcl" .

.PHONY: build-jupyterhub
build-jupyterhub: check-region init validate release.auto.pkrvars.hcl jupyterhub.pkrvars.hcl
	packer build -only="amazon-ebs.al2023" -var "region=${REGION}" --var-file="jupyterhub.pkrvars.hcl" .

.PHONY: validate-opa
validate-opa: check-region init opa.pkrvars.hcl
	packer validate -var "region=${REGION}" --var-file="opa.pkrvars.hcl" .

.PHONY: build-opa
build-opa: check-region init validate release.auto.pkrvars.hcl opa.pkrvars.hcl
	packer build -only="amazon-ebs.al2023" -var "region=${REGION}" --var-file="opa.pkrvars.hcl" .

.PHONY: validate-cape-frontend
validate-cape-frontend: check-region init cape-frontend.pkrvars.hcl
	packer validate -var "region=${REGION}" --var-file="cape-frontend.pkrvars.hcl" .

.PHONY: build-cape-frontend
build-cape-frontend: check-region init validate release.auto.pkrvars.hcl cape-frontend.pkrvars.hcl
	packer build -only="amazon-ebs.al2023" -var "region=${REGION}" --var-file="cape-frontend.pkrvars.hcl" .
