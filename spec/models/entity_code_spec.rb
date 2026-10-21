require "rails_helper"

RSpec.describe EntityCode, type: :model do
  let(:office) { create(:office, entity_code: "OFFICE-USA-NY-ASSEMBLY-AD_125") }

  def register(code, canonical_code: office.entity_code, record: office)
    EntityCode.create!(namespace: "MIC", catalog: "ASC", code: code, canonical_code: canonical_code, record: record)
  end

  it "resolves a preferred code and its aliases to the same record" do
    preferred = register("OFFICE-USA-NY-ASSEMBLY-AD_125")
    previous = register("OFFICE-USA-NY-AD_125")

    expect(preferred).not_to be_alias
    expect(previous).to be_alias
    expect([ preferred.record, previous.record ]).to all(eq(office))
  end

  it "issues each code once per namespace and catalog" do
    register("OFFICE-USA-NY-ASSEMBLY-AD_125")

    expect { register("OFFICE-USA-NY-ASSEMBLY-AD_125") }.to raise_error(ActiveRecord::RecordInvalid)
    expect(
      EntityCode.new(namespace: "MIC", catalog: "ALA", code: "OFFICE-USA-NY-ASSEMBLY-AD_125", canonical_code: "OFFICE-USA-NY-ASSEMBLY-AD_125")
    ).to be_valid
  end

  it "stops resolving a code whose canonical code no longer matches the record" do
    stale = register("OFFICE-USA-NY-AD_125", canonical_code: "OFFICE-USA-NY-AD_125_RETIRED")

    expect(stale.record).to be_nil
  end
end
