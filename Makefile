init:
	@terraform init
fmt:
	@terraform fmt
validate:
	@terraform validate
plan:
	@terraform plan -out
apply:
	@terraform apply