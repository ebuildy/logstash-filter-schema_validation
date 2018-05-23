# encoding: utf-8
require "java"
require "logstash-filter-schema_validation"
require "logstash/filters/base"
require "logstash/namespace"

java_import "java.io.FileInputStream"
java_import "com.fasterxml.jackson.databind.JsonNode"
java_import "com.fasterxml.jackson.databind.ObjectMapper"
java_import "com.github.fge.jsonschema.core.report.ProcessingReport"
java_import "com.github.fge.jsonschema.main.JsonSchema"
java_import "com.github.fge.jsonschema.main.JsonSchemaFactory"
java_import "com.github.fge.jsonschema.cfg.ValidationConfigurationBuilder"

# This  filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an .
class LogStash::Filters::SchemaValidation < LogStash::Filters::Base

  config_name "schema_validation"

  # The path to JSON schema.
  config :schema, :validate => :string, :required => true

  # Retrieve errors.
  config :report_field, :validate => :string, :default => nil

  # Tags the event on failure to look up geo information. This can be used in later analysis.
  config :tag_on_failure, :validate => :array, :default => ["_schema_validation_failure"]

  public
  def register
    @schema = File.expand_path(@schema)

    @schemaFactory = JsonSchemaFactory.newBuilder().freeze()

    @jsonMapper = ObjectMapper.new
    @validator = JsonSchemaFactory.byDefault().getValidator()

    @cacheSchema = {}
  end # def register

  public
  def filter(event)

    schemaFilePath = generate_filepath(event)

    if File.exists?(schemaFilePath)

      schema = get_schema(schemaFilePath)

      json = @jsonMapper.readTree(event.to_json)

      #validationErrors = JSON::Validator.fully_validate(schemaFilePath, event.to_hash, :strict => @strict, :fragment => @fragment, :parse_data => false)

      validationErrors = schema.validate(json)

      if validationErrors.isSuccess
        filter_matched(event)
      else
        tag_unsuccessful_lookup(event)

        unless @report_field.nil? || @report_field.empty?
          report = Array.new

          validationErrors.each do |message|
            report.push(message.getMessage)
          end

          event.set(@report_field, report)
        end
      end

    else

      @logger.fatal? && @logger.fatal("Schema file '" + schemaFilePath + "' does not exists!")

      tag_unsuccessful_lookup(event)

      unless @report_field.nil? || @report_field.empty?
        event.set(@report_field, ["Schema file '" + schemaFilePath + "' does not exists!"])
      end

    end

  end

  def tag_unsuccessful_lookup(event)
    @logger.debug? && @logger.debug("Event data is not valide!", :event => event)
    @tag_on_failure.each{|tag| event.tag(tag)}
  end

  private
  def generate_filepath(event)
    event.sprintf(@schema)
  end

  private
  def get_schema(name)
      unless @cacheSchema.key?(name)
        schema = @schemaFactory.getJsonSchema("file://" + name)
        @cacheSchema[name] = schema
      end

      return @cacheSchema[name]
  end

end
