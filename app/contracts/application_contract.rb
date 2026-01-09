# frozen_string_literal: true

# Base for all contracts
class ApplicationContract < Dry::Validation::Contract
  # Error messages stored in I18n format (in yaml resource files)
  config.messages.backend = :i18n
end
