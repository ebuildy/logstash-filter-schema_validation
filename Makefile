author = ebuildy
plugin_name = logstash-filter-schema_validation

.PHONY: build

build:
	gem build $(plugin_name).gemspec

logstash/install:
	logstash-plugin install --local $(plugin_name)-0.1.0.gem

logstash/run:
	logstash -f /usr/share/logstash/pipeline/debug.conf

test/setup:
	docker-compose build test-jruby9

test/run:
	docker-compose run -e ENV_SCHEMA=simple --rm test-jruby9
	#docker-compose run --rm test-jruby9-logstash6
	#docker-compose run --rm test-jruby9-logstash7

test/stop:
	docker-compose down

dev/run:
	GEM=$$(ls *.gem) docker-compose up --build run-logstash
