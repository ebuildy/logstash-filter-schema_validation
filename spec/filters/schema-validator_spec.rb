# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/schema_validation"

describe LogStash::Filters::SchemaValidation do
  describe "Set to Hello World" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "/wrong_file.json"
        }
      }
    CONFIG
    end

    sample("message" => "some text") do
      expect(subject).to include("tags")
    end
  end
end
