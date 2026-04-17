FactoryBot.define do
  factory :rule_topic, class: "Rule::Topic" do
    sequence(:slug) { |n| "rule-topic-#{n}" }
    sequence(:title) { |n| "Rule Topic #{n}" }
    description { "Derived permission topic for scenario guidance." }
    status { :active }
  end
end
