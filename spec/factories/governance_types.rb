FactoryBot.define do
  factory :governance_type do
    name { "MyString" }
    description { "MyText" }
    authority_level { 1 }
    decision_making_process { "MyString" }
  end
end
