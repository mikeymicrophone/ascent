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

# Seed positions (no dependencies)
puts "\n🏢 Seeding positions..."
PositionSeeder.seed

# Seed offices (depends on positions and jurisdictions)
puts "\n🏛️ Seeding offices..."
OfficeSeeder.seed

puts "\n✅ Seed process completed!"
puts "📊 Summary:"
puts "   Countries: #{Country.count}"
puts "   States: #{State.count}"
puts "   Positions: #{Position.count}"
puts "   Offices: #{Office.count}"
