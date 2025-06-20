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
