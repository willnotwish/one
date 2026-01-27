# frozen_string_literal: true

# Base config class to fetch config values from env vars
class ApplicationConfig
  class << self
    private

    def fetch_from_env!(key)
      ENV.fetch(key) do
        raise KeyError, "Missing required ENV var: #{key}"
      end
    end

    def optional_from_env(key, default)
      ENV.fetch(key, default)
    end
  end
end
