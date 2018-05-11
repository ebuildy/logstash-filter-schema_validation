author = ebuildy
plugin_name = logstash-filter-schema_validation

export COMPOSE_FILE = ./docker-compose.yml
export COMPOSER_PROJECT = $(plugin_name)

build:
	gem build $(plugin_name).gemspec

logstash/install:
	logstash-plugin install --local $(plugin_name)-0.1.0.gem

logstash/run:
	logstash -f /usr/share/logstash/pipeline/debug.conf

test/setup:
	docker-compose build

test/run:
	docker-compose run --rm test-jruby9
	#docker-compose run --rm test-jruby9-logstash6
	#docker-compose run --rm test-jruby9-logstash7

test/stop:
	docker-compose down
