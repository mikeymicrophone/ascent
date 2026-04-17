FactoryBot.define do
  factory :rule_condition, class: "Rule::Condition" do
    association :statement, factory: :rule_statement
    sequence(:slug) { |n| "rule-condition-#{n}" }
    sequence(:label) { |n| "Condition #{n}" }
    kind { :required }
    position { 0 }
    notes { "This condition must be satisfied for the statement to apply." }
  end
end
