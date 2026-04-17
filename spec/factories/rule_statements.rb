FactoryBot.define do
  factory :rule_statement, class: "Rule::Statement" do
    association :topic, factory: :rule_topic
    sequence(:slug) { |n| "rule-statement-#{n}" }
    sequence(:title) { |n| "Rule Statement #{n}" }
    effect { :conditional }
    actor_label { "person" }
    action_label { "use force" }
    object_label { "another person" }
    summary { "Force may be allowed under limited conditions." }
    status { :active }
    position { 0 }
  end
end
