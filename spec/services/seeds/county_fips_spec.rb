require "rails_helper"

RSpec.describe "County FIPS seed attributes" do
  it "imports and replays a leading-zero FIPS separately from its entity code" do
    state = create(:state, entity_code: "STATE-USA-AL")
    document = { format: "micharisma-seeds/v1", namespace: "MIC", catalog: "ASC", records: [
      { type: "County", code: "COUNTY-USA-AL-AUTAUGA", attributes: { name: "Autauga County", fips: "01001" },
        references: { state: state.entity_code } }
    ] }
    Dir.mktmpdir do |directory|
      path = File.join(directory, "county.json")
      File.write(path, document.to_json)
      importer = Seeds::LibraryImporter.new
      importer.call([ path ])
      expect(County.sole).to have_attributes(entity_code: "COUNTY-USA-AL-AUTAUGA", fips: "01001")
      expect { importer.call([ path ]) }.not_to change(County, :count)
      expect(importer.report[:conflicts]).to be_empty

      document[:records].first[:attributes] = { name: "Autauga County", code: "01001" }
      File.write(path, document.to_json)
      expect { importer.call([ path ]) }.to raise_error(Seeds::LibraryImporter::Error, /unsupported County attribute code/)
    end
  end
end
