# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'max_scale macro' do
  let(:contract) do
    Class.new(ApplicationContract) do
      register_macro(:max_scale) do |macro:|
        max_scale = macro.args[0]
        key.failure(:max_scale_exceeded, max_scale:) if value.scale > max_scale
      end

      params do
        required(:amount).filled(:decimal)
      end

      rule(:amount).validate(max_scale: 2)
    end.new
  end

  it 'accepts integers' do
    result = contract.call(amount: '10')
    expect(result).to be_success
  end

  it 'accepts one decimal place' do
    result = contract.call(amount: '10.5')
    expect(result).to be_success
  end

  it 'accepts two decimal places' do
    result = contract.call(amount: '10.55')
    expect(result).to be_success
  end

  it 'rejects four decimal places with the correct error message (including the attribute name)' do
    result = contract.call(amount: '10.5514')
    expect(result).to be_failure

    expect(result.errors(full: true).to_h[:amount]).to include('amount must not have more than 2 decimal places.')
  end
end
