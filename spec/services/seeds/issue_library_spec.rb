require "rails_helper"
require Rails.root.join("db", "seeds", "data_paths")

RSpec.describe "Issue library manifest" do
  let(:path) { SeedDataPaths.primary_root.join("manifests/library/issues.yml").to_s }
  let(:importer) { Seeds::LibraryImporter.new }

  it "imports coded topics, issues, and approaches, and re-imports without change" do
    report = importer.call([ path ])

    expect([ Topic.count, Issue.count, Approach.count ]).to eq([ 10, 40, 120 ])
    expect(report[:conflicts]).to be_empty
    approach = Approach.find_by!(entity_code: "APPROACH-EDUCATION-SCHOOL_FUNDING_SHORTFALLS-EDUCATION_REVENUE_BOND_INITIATIVE")
    expect(approach.issue).to have_attributes(entity_code: "ISSUE-EDUCATION-SCHOOL_FUNDING_SHORTFALLS", title: "School Funding Shortfalls")
    expect(approach.issue.topic.entity_code).to eq("TOPIC-EDUCATION")

    expect { importer.call([ path ]) }.not_to change { [ Topic.count, Issue.count, Approach.count, EntityCode.count ] }
    expect(importer.report[:unchanged].size).to eq(170)
  end

  it "adopts an uncoded topic with the same title" do
    education = Topic.create!(title: "Education")

    importer.call([ path ])

    expect(education.reload.entity_code).to eq("TOPIC-EDUCATION")
    expect(Topic.where(title: "Education").count).to eq(1)
  end
end
