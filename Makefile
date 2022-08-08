check-env:
	ifndef GITHUB_ACCESS_TOKEN
		$(error GITHUB_ACCESS_TOKEN is not defined, please check your .envrc.custom)
	endif

check-path:
	ifeq (, $(shell which aws))
		$(error aws-cli not installed, please install the aws-cli v2 from amazon)
	endif

clean: 
	$(MAKE) purge
	@rm -rf .docker/
	@docker ps

deps: mix.lock mix.exs
	@mix deps.get
	@mix deps.compile

purge:
ifneq (, $(shell docker container ls -q -f name="gameplatform*"))
	@>&2 echo "System id dirty, purging all gameplatform containers"
	@docker ps

	docker container rm -f $(shell docker container ls -q -f name="gameplatform*")
endif
ifneq (, $(shell docker network ls -q -f name="gameplatform*"))
	@>&2 echo "System id dirty, purging all gameplatform network"
	@docker ps

	docker network rm $(shell docker network ls -q --f name="gameplatform*")
endif

setup_test: export MIX_ENV=test
setup_test: start_db_services
	@mix ecto.setup --no-compile

reset_test: export MIX_ENV=test
reset_test: start_db_services
	@mix ecto.reset --no-compile

start_db_services:
	@docker compose up -d --wait db redis

stop: 
	@docker compose down || exit 0
	@docker compose kill || exit 0

image: check-env check-path
	${MAKE} build_base