FactoryBot.define do
  sequence :unique_utr do |n|
    # You can use a prefix if you like, and append n to guarantee uniqueness
    "#{Time.now.to_i}#{n}"
  end
end
