# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "json-schema"

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

  # JSON Schema option
  # with the `:strict` option, all properties are condisidered to have `"required": true` and all objects `"additionalProperties": false`
  config :strict, :validate => :boolean, :default => false

  # JSON Schema option
  # with the `:fragment` option, only a fragment of the schema is used for validation
  config :fragment, :validate => :string

  # JSON Schema option
  # with the `:version` option, schemas conforming to older drafts of the json schema spec can be used
  config :spec_version, :validate => :string, :default => "draft2"

  # Tags the event on failure to look up geo information. This can be used in later analysis.
  config :tag_on_failure, :validate => :array, :default => ["_schema_validation_failure"]

  public
  def register
    @schema = File.expand_path(@schema)
  end # def register

  public
  def filter(event)

    schemaFilePath = generate_filepath(event)

    if File.exists?(schemaFilePath)

      validationErrors = JSON::Validator.fully_validate(schemaFilePath, event.to_hash, :strict => @strict, :fragment => @fragment)

      if validationErrors.empty?
        filter_matched(event)
      else
        tag_unsuccessful_lookup(event)

        unless @report_field.nil? || @report_field.empty?
          event.set(@report_field, validationErrors)
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

end
