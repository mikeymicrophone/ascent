FactoryBot.define do
  factory :rule_source_link, class: "Rule::SourceLink" do
    association :linkable, factory: :rule_statement
    sequence(:lu_unit_id) { |n| n }
    relationship_kind { :primary_support }
    notes { "Primary source support for this derived rule record." }
  end
end
