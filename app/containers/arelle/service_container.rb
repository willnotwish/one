# frozen_string_literal: true

module Arelle
  # app/containers/hmrc_container.rb
  class ServiceContainer
    extend Dry::Container::Mixin

    register(:xml_parser) { NokogiriParser.new }

    namespace(:validations) do
      register(:arelle_client) { External::Arelle::ValidationApiClient.new }
      register(:arelle_response_parser) { Arelle::Ixbrl::ValidationResponseParser.new }
    end
  end
end
