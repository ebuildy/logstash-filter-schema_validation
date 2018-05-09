build:
	gem build logstash-filter-schema_validation.gemspec

logstash/install:
	logstash-plugin install --local logstash-filter-schema_validation-0.1.0.gem

logstash/run:
	logstash -f /usr/share/logstash/pipeline/debug.conf

dev/tester/run:
	docker run -ti --rm jruby:9 bash
