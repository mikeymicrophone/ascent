# Fills an election with invented demo activity for trying its pages in development. The tooling is
# shared; the data it makes stays in each developer's own database.
namespace :seed_data do
  desc "Fill one election with invented demo activity: bin/rails 'seed_data:demo_election[1681]'"
  task :demo_election, [ :election_id ] => :environment do |_task, args|
    require Rails.root.join("db", "seeds", "demo_election_seeder")
    abort "Demo data is for development only" if Rails.env.production?

    puts DemoElectionSeeder.new(Election.find(args.fetch(:election_id))).seed!.map { |key, value| "#{key}: #{value}" }
  end

  desc "Remove one election's demo activity: bin/rails 'seed_data:clear_demo_election[1681]'"
  task :clear_demo_election, [ :election_id ] => :environment do |_task, args|
    require Rails.root.join("db", "seeds", "demo_election_seeder")
    DemoElectionSeeder.new(Election.find(args.fetch(:election_id))).clear!
    puts "Cleared demo data for election #{args.fetch(:election_id)}"
  end
end
