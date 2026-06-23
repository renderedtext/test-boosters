SHELL := /bin/sh
BUNDLE ?= bundle
DOCKER ?= docker
RUBY_VERSION ?= 3.3
BUNDLER_VERSION ?=
IMAGE_PREFIX ?= semaphore-test-boosters
IMAGE ?= $(IMAGE_PREFIX):ruby-$(RUBY_VERSION)
RUBY2_VERSION ?= 2.6.10
RUBY3_VERSION ?= 3.3
RUBY4_VERSION ?= 4.0.5
BUNDLE_GEMFILE ?= Gemfile.docker
OUT_DIR ?= out
LINT_IMAGE ?= $(IMAGE_PREFIX):lint-ruby-$(RUBY2_VERSION)

.PHONY: help deps test test-all lint clean docker-build docker-test docker-test-ci docker-lint docker-audit docker-shell docker-test-ruby2 docker-test-ruby3 docker-test-ruby4 docker-test-matrix

help:
	@echo "Available targets:"
	@echo "  deps         Install gem dependencies"
	@echo "  test         Run unit tests (spec/lib)"
	@echo "  test-all     Run full test suite"
	@echo "  lint         Run RuboCop checks"
	@echo "  clean        Remove local build artifacts"
	@echo "  docker-build Build Docker image"
	@echo "  docker-test  Run unit tests in Docker"
	@echo "  docker-test-ci Run unit tests in Docker and write JUnit XML to $(OUT_DIR)/test-reports.xml (CI)"
	@echo "  docker-lint  Run RuboCop in Docker on Ruby $(RUBY2_VERSION) (CI)"
	@echo "  docker-audit Run bundler-audit against Gemfile.lock in Docker (CI)"
	@echo "  docker-test-ruby2 Run unit tests in Docker using Ruby $(RUBY2_VERSION)"
	@echo "  docker-test-ruby3 Run unit tests in Docker using Ruby $(RUBY3_VERSION)"
	@echo "  docker-test-ruby4 Run unit tests in Docker using Ruby $(RUBY4_VERSION)"
	@echo "  docker-test-matrix Run Docker unit tests for Ruby $(RUBY2_VERSION), $(RUBY3_VERSION), and $(RUBY4_VERSION)"
	@echo "  docker-shell Open an interactive shell in Docker"

deps:
	$(BUNDLE) config set --local path vendor/bundle
	$(BUNDLE) install

test:
	$(BUNDLE) exec rspec spec/lib

test-all:
	$(BUNDLE) exec rspec

lint:
	$(BUNDLE) exec rubocop lib spec

clean:
	rm -rf coverage tmp vendor/bundle .bundle

docker-build:
	$(DOCKER) build \
		--build-arg RUBY_VERSION=$(RUBY_VERSION) \
		--build-arg BUNDLE_GEMFILE=$(BUNDLE_GEMFILE) \
		$(if $(BUNDLER_VERSION),--build-arg BUNDLER_VERSION=$(BUNDLER_VERSION),) \
		-t $(IMAGE) .

docker-test: docker-build
	$(DOCKER) run --rm -t -w /app $(IMAGE) bundle exec rspec spec/lib

docker-test-ci: docker-build
	mkdir -p $(OUT_DIR)
	$(DOCKER) run --rm -t -v "$(PWD)/$(OUT_DIR):/app/$(OUT_DIR)" -w /app $(IMAGE) \
		bundle exec rspec spec/lib \
		--format progress \
		--format RspecJunitFormatter --out $(OUT_DIR)/test-reports.xml

docker-lint:
	$(DOCKER) build \
		--build-arg RUBY_VERSION=$(RUBY2_VERSION) \
		--build-arg BUNDLE_GEMFILE=Gemfile \
		-t $(LINT_IMAGE) .
	$(DOCKER) run --rm -t -w /app $(LINT_IMAGE) bundle exec rubocop lib spec

docker-audit:
	$(DOCKER) run --rm -t -v "$(PWD):/app" -w /app ruby:$(RUBY2_VERSION)-slim \
		sh -c "apt-get update >/dev/null && apt-get install -y --no-install-recommends git >/dev/null \
		&& gem install bundler-audit --no-document \
		&& bundle lock \
		&& bundle-audit update \
		&& bundle-audit check"

docker-test-ruby2:
	$(MAKE) docker-test RUBY_VERSION=$(RUBY2_VERSION)

docker-test-ruby3:
	$(MAKE) docker-test RUBY_VERSION=$(RUBY3_VERSION)

docker-test-ruby4:
	$(MAKE) docker-test RUBY_VERSION=$(RUBY4_VERSION)

docker-test-matrix:
	$(MAKE) docker-test-ruby2
	$(MAKE) docker-test-ruby3
	$(MAKE) docker-test-ruby4

docker-shell:
	$(DOCKER) run --rm -it -v "$(PWD):/app" -w /app $(IMAGE) /bin/bash
