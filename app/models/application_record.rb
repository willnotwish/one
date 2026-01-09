# frozen_string_literal: true

# Base for all AR  models
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
