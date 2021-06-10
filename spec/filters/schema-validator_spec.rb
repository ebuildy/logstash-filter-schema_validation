# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/schema_validation"

describe LogStash::Filters::SchemaValidation do

  before do
    srand(RSpec.configuration.seed)
  end

  describe "With not existing schema file I should see the failure tag" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "/wrong_file.json"
          report_field => "_errors"
          tag_on_failure => "fail"
        }
      }
    CONFIG
    end

    sample("message" => "some text") do
      expect(subject).to include("tags")
      expect(subject).to include("_errors")
      expect(subject.get("tags")).to eq(["fail"])
      expect(subject.get("_errors")).to eq(["Schema file '" + "/wrong_file.json" + "' does not exists!"])
    end
  end

  describe "With a valid schema I should not see the failure tag" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/simple.json"
          report_field => "_errors"
        }
      }
    CONFIG
    end

    sample("firstName" => "tom", "lastName" => "Decaux", "age" => 34) do
      expect(subject).not_to include("tags")
    end
  end

  describe "With fragment I should not see the failure tag" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/simple0.json"
          report_field => "_errors"
          fragment => "#/properties/name"
        }
      }
    CONFIG
    end

    sample("first" => "tom", "last" => "Decaux") do
#      puts subject.to_hash.to_s
      expect(subject).not_to include("tags")
    end
  end

  describe "Without respecting the schema I should see the failure tag and the error details" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/simple.json"
          report_field => "_errors"
        }
      }
    CONFIG
    end

    sample("firstName" => "tom", "lastame" => "Decaux", "age" => 34) do
      expect(subject).to include("tags")
      expect(subject.get("_errors")[0]).to include("The property '#/' did not contain a required property of 'lastName'")
    end
  end

  describe "With strict mode and an extra field I should get an error" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/simple.json"
          strict => true
        }
      }
    CONFIG
    end

    sample("firstName" => "tom", "lastName" => "Decaux", "age" => 34, "sex" => "enormous") do
      expect(subject).to include("tags")
    end
  end

  describe "I should specify the schema file via environment variable" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/${ENV_SCHEMA}.json"
          report_field => "_errors"
        }
      }
    CONFIG
    end

    sample("firstName" => "tom", "lastName" => "Decaux", "age" => 34, "sex" => "enormous") do
      expect(subject).not_to include("tags")
    end
  end

  describe "I should specify the schema file via event data" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/%{schema}.json"
          report_field => "_errors"
        }
      }
    CONFIG
    end

    sample("firstName" => "tom", "lastName" => "Decaux", "age" => 34, "sex" => "enormous", "schema" => "simple") do
      expect(subject).not_to include("tags")
    end
  end

  describe "I should specify the target in the message" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/${ENV_SCHEMA}.json"
          report_field => "_errors"
          target => "log_processed"
        }
      }
    CONFIG
    end

    sample("log_processed" => {"firstName" => "tom", "lastName" => "Decaux", "age" => 34, "sex" => "enormous"}) do
      expect(subject).not_to include("tags")
    end
  end

  describe "Should give same error when target is present" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/${ENV_SCHEMA}.json"
          report_field => "_errors"
          target => "log_processed"
        }
      }
    CONFIG
    end

    sample("log_processed" => {"firstName" => "tom", "age" => 34}) do
      expect(subject).to include("tags")
      expect(subject.get("_errors")[0]).to include("The property '#/' did not contain a required property of 'lastName'")
    end
  end

  describe "Should give error when the selected target is not present" do
    let(:config) do <<-CONFIG
      filter {
        schema_validation {
          schema => "./spec/schemas/${ENV_SCHEMA}.json"
          target => "log_processed"
          report_field => "_errors"
          tag_on_failure => "fail"
        }
      }
    CONFIG
    end

    sample("firstName" => "tom", "age" => 34) do
      expect(subject).to include("tags")
      expect(subject).to include("_errors")
      expect(subject.get("tags")).to eq(["fail"])
      expect(subject.get("_errors")).to eq(["Target '" + "log_processed" + "' does not exists in message"])
    end
  end
end
