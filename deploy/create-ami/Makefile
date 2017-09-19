ami:
	packer build -var-file variables.json packer.json

docker:
	packer build -var-file variables.json -on-error=ask packer-docker.json
