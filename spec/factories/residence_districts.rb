FactoryBot.define do
  # A district recorded by hand for a residence, where no boundary places it.
  factory :residence_district do
    association :residence
    association :jurisdiction, factory: [ :jurisdiction, :district ]
  end
end
