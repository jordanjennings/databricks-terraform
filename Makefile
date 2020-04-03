default: build

test:
	@echo "==> Running tests..."
	@gotestsum --raw-command go test -v -json -short -coverprofile=coverage.out ./...

int:
	@echo "==> Running tests..."
	@gotestsum --raw-command go test -v -json -coverprofile=coverage.out ./...

coverage: test
	@echo "==> Opening coverage for unit tests..."
	@go tool cover -html=coverage.out

int-build: int build

build:
	@echo "==> Building source code with go build..."
	@go build -mod vendor -v -o terraform-provider-db

fmt:
	@echo "==> Formatting source code with gofmt..."
	@go fmt ./...


python-setup:
	@echo "==> Setting up virtual env and installing python libraries..."
	@python -m pip install virtualenv
	@cd docs && python -m virtualenv venv
	@cd docs && source venv/bin/activate && python -m pip install -r requirements.txt

docs:
	@echo "==> Building Docs ..."
	@cd docs && source venv/bin/activate && make html

opendocs: docs
	@echo "==> Opening Docs ..."
	@cd docs && open build/html/index.html

vendor:
	@echo "==> Filling vendor folder with library code..."
	@go mod vendor

# INTEGRATION TESTING WITH TERRAFORM EXAMPLES
terraform-setup: fmt build
	@echo "==> Initializing Terraform..."
	@terraform init

terraform-apply: terraform-setup
	@echo "==> Initializing Terraform plan..."
	@TF_LOG_PATH=log.out TF_LOG=debug terraform apply

.PHONY: build fmt python-setup docs vendor terraform-local build fmt coverage test