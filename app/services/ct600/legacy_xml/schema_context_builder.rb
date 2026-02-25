# frozen_string_literal: true

module Ct600
  module LegacyXml
    # Pure (stateless) monadic service: determines CT600 legacy xml schema version for a given accounting period
    class SchemaContextBuilder
      include Dry::Monads[:result]

      SCHEMA_RULES = [
        { effective_from: Date.new(2023, 4, 1), schema: '2023-04-01' },
        { effective_from: Date.new(2024, 4, 1), schema: '2024-04-01' },
        { effective_from: Date.new(2026, 4, 1), schema: '2026-04-01' }
        # Add future versions here
      ].freeze

      def self.available_versions
        SCHEMA_RULES.map { |r| r[:schema] }
      end

      def call(period: nil, schema_version: nil)
        if schema_version
          rule = SCHEMA_RULES.find { |r| r[:schema] == schema_version }
          return Failure("Unknown schema version: #{schema_version}") unless rule
        elsif period
          rule = SCHEMA_RULES.reverse.find { |r| period.ends_on >= r[:effective_from] }
          return Failure("No schema version found for period ending #{period.ends_on}") unless rule
        else
          return Failure('Must provide either period or schema_version')
        end

        Success(context_from_rule(rule))
      end

      private

      def context_from_rule(rule)
        xsd_path = Rails.root.join("/taxonomies/ct600/#{rule[:schema]}/CT600.xsd")
        xsd = Nokogiri::XML::Schema(File.read(xsd_path))

        SchemaContext.new(
          version: rule[:schema],
          xsd: xsd,
          namespace: "urn:hmrc:ct:ct600:v#{rule[:schema].gsub('-', '')}"
        )
      end
    end
  end
end
