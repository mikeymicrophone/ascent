require "rails_helper"

RSpec.describe Seeds::BallotManifestConverter do
  let(:root) { Rails.root.join("tmp", "ballot_manifest_converter_spec") }

  def row(office, district, name, party, status: "certified", level: nil, county: "", jurisdiction: "", notes: "")
    {
      "election_date" => "2026-11-03", "state" => "NY", "office" => office, "district" => district,
      "office_level" => level || (district.empty? ? "state" : "federal"), "candidate_name" => name, "party" => party,
      "incumbent" => "", "status" => status, "source_url" => "https://elections.ny.gov/certification",
      "retrieved_on" => "2026-10-01", "vote_for" => "1", "notes" => notes, "county" => county, "jurisdiction" => jurisdiction
    }
  end

  def write(relative, contents)
    path = root.join(relative)
    FileUtils.mkdir_p(path.dirname)
    path.write(contents)
  end

  before do
    FileUtils.rm_rf(root)
    write("us_states.yml", { "states" => [ { "code" => "NY", "name" => "New York", "country_code" => "US" } ] }.to_yaml)
    write("positions.yml", [ { "title" => "Sheriff", "description" => "The chief law enforcement officer for a county.", "branch" => "executive" } ].to_yaml)
    write("races/2026/new_york/state/governor.yml", [
      row("Governor", "", "Kathy Hochul", "Democratic"),
      row("Governor", "", "Kathy Hochul", "Working Families")
    ].to_yaml)
    write("races/2026/new_york/federal/representative_in_congress.yml", [
      row("Representative in Congress", "15", "Ritchie J. Torres", "Democratic"),
      row("Representative in Congress", "15", "Jose Vega", "Speak The Truth")
    ].to_yaml)
    write("races/2026/new_york/conflicts.csv", <<~CSV)
      state,office,district,candidate_name,field,value_a,source_a,value_b,source_b,note
      NY,Governor,,Paul Mailhot,presence,not listed,https://elections.ny.gov,listed; balloted=Write-in,https://www.thegreenpapers.com,Green Papers lists this person
      NY,Representative in Congress,15,Ritchie J. Torres,candidate_name,Ritchie J. Torres,https://elections.ny.gov,"TORRES, RITCHIE",https://www.fec.gov,name form differs
    CSV
    write("conversion/2026/new_york/rules.yml", {
      "parties" => [
        { "code" => "DEMOCRATIC", "name" => "Democratic", "labels" => [ "Democratic" ] },
        { "code" => "WORKING_FAMILIES", "name" => "Working Families", "labels" => [ "Working Families" ] }
      ],
      "other_labels" => "designation",
      "unprinted_labels" => [ "Nonpartisan" ],
      "special_elections" => [ "- Special\\z" ]
    }.to_yaml)
  end

  after { FileUtils.rm_rf(root) }

  def convert(random: Random.new)
    described_class.new(state_dir: "new_york", selection: :all, root: root, random: random).call
  end

  # A username is the surname, the given name's first letter and next consonant, and a disambiguator.
  def username_like(base)
    /\A#{base}_[2-9][a-hj-np-z]\z/
  end

  it "writes manifests that the importer turns into races, ballot lines, and endorsements" do
    convert
    Year.create!(year: 2026, is_even_year: true, is_presidential_year: false)

    report = Seeds::LibraryImporter.new.call(Dir.glob(root.join("manifests/**/*.yml").to_s))

    expect(report[:conflicts]).to be_empty
    governor = Race.find_by!(entity_code: "RACE-USA-NY-GOVERNOR-2026_GENERAL")
    expect(governor.election).to have_attributes(entity_code: "ELECTION-USA-NY-2026_GENERAL", name: "New York General Election 2026")
    expect(governor.certification_status).to eq("certified")
    hochul = governor.candidacies.joins(:person).find_by!(people: { last_name: "Hochul" })
    expect(hochul.person.username).to match(username_like("hochul_kt"))
    expect(hochul.person.entity_code).to eq("PERSON-#{hochul.person.username.upcase}")
    expect(hochul.ballot_labels).to eq("Democratic; Working Families")
    expect(hochul.endorsements.map { |endorsement| endorsement.endorser.entity_code })
      .to contain_exactly("PARTY-USA-NY-DEMOCRATIC", "PARTY-USA-NY-WORKING_FAMILIES")

    write_in = governor.candidacies.joins(:person).find_by!(people: { last_name: "Mailhot" })
    expect(write_in).to have_attributes(participation: "off_ballot")
    expect(write_in.ballot_lines).to be_empty

    house = Race.find_by!(entity_code: "RACE-USA-NY-CONGRESS-CD_15-2026_GENERAL")
    expect(house.office).to have_attributes(seat_code: "CD_15", jurisdiction: District.find_by!(name: "New York Congressional District 15").jurisdiction)
    vega = house.candidacies.joins(:person).find_by!(people: { last_name: "Vega" })
    expect(vega.ballot_lines.sole).to have_attributes(label: "Speak The Truth", kind: "designation", party: nil)
    expect(vega.endorsements).to be_empty
  end

  it "reports its judgments and keeps issued usernames on later runs" do
    convert
    usernames = YAML.load_file(root.join("conversion/2026/new_york/usernames.yml"))
    torres = usernames.fetch("Representative in Congress|15|Ritchie J. Torres")
    expect(torres).to match(username_like("torres_rt"))

    spellings = YAML.load_file(root.join("conversion/2026/new_york/name_spellings.yml"))
    expect(spellings.sole).to include("username" => torres, "other_spelling" => "TORRES, RITCHIE")

    judgments = root.join("conversion/2026/new_york/judgments.md").read
    expect(judgments).to include("Paul Mailhot (Governor)", "- designation: Speak The Truth", "- party: Democratic, Working Families")

    usernames["Representative in Congress|15|Ritchie J. Torres"] = "ritchietorres"
    root.join("conversion/2026/new_york/usernames.yml").write(usernames.to_yaml)
    summary = convert

    expect(summary[:usernames_issued]).to eq(0)
    expect(root.join("manifests/2026/new_york/congress.yml").read).to include("PERSON-RITCHIETORRES")
  end

  it "places local contests in their town, county, or a district for several places" do
    write("races/2026/new_york/local/erie.yml", [
      row("Sheriff", "", "John C. Garcia", "Republican", level: "local", county: "Erie"),
      row("Town Supervisor", "Town of Aurora", "James J. Bach", "Nonpartisan", level: "local", county: "Erie", jurisdiction: "Aurora"),
      row("School Board - Special", "Seat 2", "Ann Lee", "Nonpartisan", level: "local", county: "Erie; Niagara")
    ].to_yaml)

    convert
    Year.create!(year: 2026, is_even_year: true, is_presidential_year: false)
    report = Seeds::LibraryImporter.new.call(Dir.glob(root.join("manifests/**/*.yml").to_s))

    expect(report[:conflicts]).to be_empty
    sheriff = Race.find_by!(entity_code: "RACE-USA-NY-COUNTY_ERIE-SHERIFF-2026_GENERAL")
    expect(sheriff.office.jurisdiction.jurisdictionable).to eq(County.find_by!(name: "Erie County"))
    expect(sheriff.candidacies.sole.person.username).to match(username_like("garcia_jh"))

    aurora = Municipality.find_by!(name: "Aurora")
    expect(aurora.county.name).to eq("Erie County")
    supervisor = Race.find_by!(entity_code: "RACE-USA-NY-AURORA-TOWN_SUPERVISOR-TOWN_OF_AURORA-2026_GENERAL")
    expect(supervisor.office).to have_attributes(seat_code: "TOWN_OF_AURORA", jurisdiction: aurora.jurisdiction)
    expect(supervisor.candidacies.sole.ballot_lines).to be_empty

    school = Race.find_by!(entity_code: "RACE-USA-NY-SCHOOL_BOARD_SPECIAL-ERIE_COUNTY_NIAGARA_COUNTY-SEAT_2-2026_SPECIAL")
    expect(school.election).to have_attributes(kind: "special", name: "New York School Board - Special (Erie County, Niagara County) Special Election 2026")
    expect(Position.find_by!(title: "School Board - Special").description).to eq("Office title as printed on 2026 official candidate lists.")
    curated = YAML.load_file(root.join("manifests/foundation.yml")).fetch("records").find { |entry| entry.dig("attributes", "title") == "Sheriff" }
    expect(curated["attributes"]).to eq("title" => "Sheriff")
  end

  # Connecticut's towns belong to planning regions rather than the counties its ballots still print.
  # This made-up region stands in for one in the New York fixture.
  describe "a state that lists county-equivalents" do
    before do
      write("conversion/2026/new_york/county_equivalents.yml", { "counties" => [
        { "code" => "COUNTY-USA-NY-SOUTHTOWNS", "name" => "Southtowns Planning Region", "towns" => [ "Aurora", "Holland" ] }
      ] }.to_yaml)
    end

    it "takes each town's county from the list instead of the printed county" do
      write("races/2026/new_york/local/erie.yml", [
        row("Town Supervisor", "Town of Aurora", "James J. Bach", "Nonpartisan", level: "local", county: "Erie", jurisdiction: "Aurora"),
        row("Town Clerk", "", "Dana Wu", "Nonpartisan", level: "local", county: "Erie", jurisdiction: "Holland")
      ].to_yaml)

      convert
      Year.create!(year: 2026, is_even_year: true, is_presidential_year: false)
      report = Seeds::LibraryImporter.new.call(Dir.glob(root.join("manifests/**/*.yml").to_s))

      expect(report[:conflicts]).to be_empty
      expect(Municipality.find_by!(name: "Aurora").county.name).to eq("Southtowns Planning Region")
      expect(Municipality.find_by!(name: "Holland").county.entity_code).to eq("COUNTY-USA-NY-SOUTHTOWNS")
      expect(County.where(name: "Erie County")).not_to exist
      expect(root.join("manifests/2026/new_york/local/southtowns.yml")).to exist
      expect(Race.find_by!(entity_code: "RACE-USA-NY-AURORA-TOWN_SUPERVISOR-TOWN_OF_AURORA-2026_GENERAL")).to be_present
    end

    it "refuses a town the list leaves out" do
      write("races/2026/new_york/local/erie.yml", [
        row("Town Supervisor", "Town of Elma", "Ann Lee", "Nonpartisan", level: "local", county: "Erie", jurisdiction: "Elma")
      ].to_yaml)

      expect { convert }.to raise_error(Seeds::BallotManifestConverter::Error, /Elma is missing from county_equivalents.yml/)
    end
  end

  # Ballots print "Town of Aurora"; the Census-based municipalities list the town as Aurora.
  describe "places a contribution already lists" do
    def contribute_places(*places)
      write("manifests/contributions/census/ny_municipalities.yml", {
        "format" => "micharisma-seeds/v1", "namespace" => "MIC", "catalog" => "ASC",
        "records" => places.map { |code, name| { "type" => "Municipality", "code" => code, "attributes" => { "name" => name } } }
      }.to_yaml)
    end

    def supervisor(jurisdiction)
      write("races/2026/new_york/local/erie.yml", [
        row("Town Supervisor", "", "James J. Bach", "Nonpartisan", level: "local", county: "Erie", jurisdiction: jurisdiction)
      ].to_yaml)
    end

    it "uses the contribution's code and name instead of minting its own" do
      contribute_places([ "MUNICIPALITY-USA-NY-AURORA", "Aurora" ])
      supervisor("Town of Aurora")

      convert

      foundation = root.join("manifests/2026/new_york/foundation.yml").read
      expect(foundation).not_to include("TOWN_OF_AURORA")
      expect(root.join("manifests/2026/new_york/local/erie.yml").read).to include("OFFICE-USA-NY-AURORA-TOWN_SUPERVISOR", "office: OFFICE-USA-NY-AURORA-TOWN_SUPERVISOR")
    end

    it "settles a town and village of one name by the printed type" do
      contribute_places([ "MUNICIPALITY-USA-NY-AURORA_TOWN", "Aurora" ], [ "MUNICIPALITY-USA-NY-AURORA_VILLAGE", "Aurora" ])
      supervisor("Town of Aurora")

      convert

      expect(root.join("manifests/2026/new_york/local/erie.yml").read).to include("OFFICE-USA-NY-AURORA_TOWN-TOWN_SUPERVISOR")
    end

    it "asks place_codes.yml to settle a tie the printed name cannot" do
      contribute_places([ "MUNICIPALITY-USA-NY-AURORA_TOWN", "Aurora" ], [ "MUNICIPALITY-USA-NY-AURORA_VILLAGE", "Aurora" ])
      supervisor("Aurora")

      expect { convert }.to raise_error(Seeds::BallotManifestConverter::Error, /Aurora could be MUNICIPALITY-USA-NY-AURORA_TOWN or MUNICIPALITY-USA-NY-AURORA_VILLAGE; choose one in place_codes.yml/)

      write("conversion/2026/new_york/place_codes.yml", { "Aurora" => "MUNICIPALITY-USA-NY-AURORA_VILLAGE" }.to_yaml)
      convert

      expect(root.join("manifests/2026/new_york/local/erie.yml").read).to include("OFFICE-USA-NY-AURORA_VILLAGE-TOWN_SUPERVISOR")
    end
  end

  it "gives each judge standing for retention a race of their own" do
    retention_note = "appellate judge (Florida appellate judges stand for merit retention, yes/no)"
    write("races/2026/new_york/state/appeal.yml", [
      row("District Court of Appeal", "1", "Joseph Lewis Jr.", "", notes: retention_note),
      row("District Court of Appeal", "1", "Rachel Nordby", "", notes: retention_note)
    ].to_yaml)

    convert

    usernames = YAML.load_file(root.join("conversion/2026/new_york/usernames.yml"))
    lewis, nordby = usernames.values_at("District Court of Appeal|1|Joseph Lewis Jr.", "District Court of Appeal|1|Rachel Nordby")
    expect(lewis).to match(username_like("lewis_js"))
    expect(nordby).to match(username_like("nordby_rc"))
    judicial = root.join("manifests/2026/new_york/judicial.yml").read
    expect(judicial).to include("RACE-USA-NY-APPEAL-DCA_1-APPELLATE_JUDGE-RETENTION_OF_JOSEPH_LEWIS_JR-2026_GENERAL",
                                "RACE-USA-NY-APPEAL-DCA_1-APPELLATE_JUDGE-RETENTION_OF_RACHEL_NORDBY-2026_GENERAL")
  end

  it "gives two people with the same printed name the same name code and different disambiguators" do
    write("races/2026/new_york/state/state_senator.yml", [
      row("State Senator", "1", "John Smith", "Republican"),
      row("State Senator", "2", "John Smith", "Republican")
    ].to_yaml)

    convert

    usernames = YAML.load_file(root.join("conversion/2026/new_york/usernames.yml"))
    first, second = usernames.values_at("State Senator|1|John Smith", "State Senator|2|John Smith")
    expect([ first, second ]).to all(match(username_like("smith_jh")))
    expect(first).not_to eq(second)
  end

  it "abbreviates the given name to its first letter and next consonant" do
    write("races/2026/new_york/state/attorney_general.yml", [
      row("Attorney General", "", "Letitia A. James", "Democratic"),
      row("Attorney General", "", "Ann Yee", "Republican")
    ].to_yaml)

    convert

    usernames = YAML.load_file(root.join("conversion/2026/new_york/usernames.yml"))
    expect(usernames.fetch("Attorney General||Letitia A. James")).to match(username_like("james_lt"))
    expect(usernames.fetch("Attorney General||Ann Yee")).to match(username_like("yee_an"))
  end

  # Usernames name no state, so a disambiguator already issued in another state is never reissued.
  it "skips a username another state has already issued" do
    write("conversion/2026/florida/usernames.yml", { "Governor||Kathy Hochul" => "hochul_kt_2a" }.to_yaml)
    # Draws the first disambiguator twice, then the last one.
    exhausted = Class.new do
      def initialize = @calls = 0
      def rand(max) = (@calls += 1) <= 2 ? 0 : max - 1
    end.new

    convert(random: exhausted)

    usernames = YAML.load_file(root.join("conversion/2026/new_york/usernames.yml"))
    expect(usernames.fetch("Governor||Kathy Hochul")).to eq("hochul_kt_9z")
  end
end
