.PHONY: check-packer
check-packer:
	@bash -c "if ! command -v packer &> /dev/null; then echo 'ERROR: packer could not be found. Make sure it is installed and in the PATH'; exit 1; fi"

.PHONY: init
init:
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
