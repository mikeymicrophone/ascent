namespace :seed_data do
  desc "Populate a fictional Governor race with shared approaches and profile media"
  task profile_scenario: :environment do
    abort "Profile scenarios are for development only" unless Rails.env.development?
    require Rails.root.join("db/seeds/profile_scenario_seeder")
    puts ProfileScenarioSeeder.new.seed!.to_json
  end
end
