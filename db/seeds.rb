# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load all seeder classes
Dir[Rails.root.join('db/seeds/*.rb')].each { |f| require f }

puts "🌱 Starting seed process..."

# Seed countries first (no dependencies)
puts "\n📍 Seeding countries..."
CountrySeeder.seed(Rails.root.join('db/seeds/data/countries.yml'))

# Seed states (depends on countries)
puts "\n🏛️ Seeding states..."
StateSeeder.seed([
  Rails.root.join('db/seeds/data/us_states.yml'),
  Rails.root.join('db/seeds/data/canadian_provinces.yml')
])

# Seed cities (depends on states)
puts "\n🏙️ Seeding cities..."
CitySeeder.seed

# Seed positions (no dependencies)
puts "\n🏢 Seeding positions..."
PositionSeeder.seed

# Seed governance types (no dependencies)
puts "\n⚖️ Seeding governance types..."
GovernanceTypeSeeder.seed

# Seed areas of concern (no dependencies)
puts "\n🎯 Seeding areas of concern..."
AreaOfConcernSeeder.seed

# Seed topics (no dependencies)
puts "\n📋 Seeding topics..."
TopicSeeder.seed

# Seed issues (depends on topics)
puts "\n⚠️ Seeding issues..."
IssueSeeder.seed

# Seed approaches (depends on issues)
puts "\n💡 Seeding approaches..."
ApproachSeeder.seed

# Seed governing bodies (depends on governance types and jurisdictions)
puts "\n🏛️ Seeding governing bodies..."
GoverningBodySeeder.seed

# Seed policies (depends on governing bodies, areas of concern, and approaches)
puts "\n📋 Seeding policies..."
PolicySeeder.seed

# Seed official codes (depends on policies)
puts "\n📜 Seeding official codes..."
OfficialCodeSeeder.seed

# Seed offices (depends on positions and jurisdictions)
puts "\n🏛️ Seeding offices..."
OfficeSeeder.seed

# Seed years (no dependencies)
puts "\n📅 Seeding years..."
YearSeeder.seed

# Seed elections (depends on offices and years)
puts "\n🗳️ Seeding elections..."
ElectionSeeder.seed

# Seed people (no dependencies)
puts "\n👥 Seeding people..."
PersonSeeder.seed

# Seed candidacies (depends on people and elections)
puts "\n🏃 Seeding candidacies..."
CandidacySeeder.seed

# Seed stances (depends on candidacies, issues, and approaches)
puts "\n🎯 Seeding candidate stances..."
StanceSeeder.seed

# Seed voters (no dependencies)
puts "\n🗳️ Seeding voters..."
VoterSeeder.seed

# Seed residences (depends on voters and jurisdictions)
puts "\n🏠 Seeding residences..."
ResidenceSeeder.seed

# Seed ratings (depends on voters and candidacies)
puts "\n⭐ Seeding ratings..."
RatingSeeder.seed

# Seed voter election baselines (depends on voters, elections, and ratings)
puts "\n🎯 Seeding voter election baselines..."
VoterElectionBaselineSeeder.seed

puts "\n✅ Seed process completed!"
puts "📊 Summary:"
puts "   Countries: #{Country.count}"
puts "   States: #{State.count}"
puts "   Cities: #{City.count}"
puts "   Positions: #{Position.count}"
puts "   Governance Types: #{GovernanceType.count}"
puts "   Areas of Concern: #{AreaOfConcern.count}"
puts "   Topics: #{Topic.count}"
puts "   Issues: #{Issue.count}"
puts "   Approaches: #{Approach.count}"
puts "   Stances: #{Stance.count}"
puts "   Governing Bodies: #{GoverningBody.count}"
puts "   Policies: #{Policy.count}"
puts "   Official Codes: #{OfficialCode.count}"
puts "   Offices: #{Office.count}"
puts "   Years: #{Year.count}"
puts "   Elections: #{Election.count}"
puts "   People: #{Person.count}"
puts "   Candidacies: #{Candidacy.count}"
puts "   Voters: #{Voter.count}"
puts "   Residences: #{Residence.count}"
puts "   Ratings: #{Rating.count}"
puts "   Rating Archives: #{RatingArchive.count}"
puts "   Voter Election Baselines: #{VoterElectionBaseline.count}"
