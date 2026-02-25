# frozen_string_literal: true

module Ct600
  module LegacyXml
    # Rendering context for legacy CT600 XML generator & validator
    class SchemaContext < Dry::Struct
      # Version string, e.g. "2026-04-01"
      attribute :version, Types::String

      # Pre-loaded Nokogiri::XML::Schema instance
      attribute :xsd, Types.Instance(Nokogiri::XML::Schema)

      # Target XML namespace for the submission
      attribute :namespace, Types::String
    end
  end
end
