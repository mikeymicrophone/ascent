require "spec_helper"
require "json"
require "open3"
require "rbconfig"

RSpec.describe "Staging configuration" do
  def staging_configuration(host: nil)
    environment = {
      "APP_HOST" => host,
      "SECRET_KEY_BASE" => "a" * 128,
      "DATABASE_URL" => "postgis://localhost/ascent_staging",
      "CACHE_DATABASE_URL" => "postgis://localhost/ascent_staging_cache",
      "QUEUE_DATABASE_URL" => "postgis://localhost/ascent_staging_queue",
      "CABLE_DATABASE_URL" => "postgis://localhost/ascent_staging_cable",
      "GOOGLE_CLIENT_ID" => "staging-client-id",
      "GOOGLE_CLIENT_SECRET" => "staging-client-secret",
      "POSTSHIBA_API_KEY" => "staging-mail-key"
    }
    script = <<~RUBY
      configurations = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)
      session = ActionDispatch::Integration::Session.new(Rails.application)
      session.host!("begin.ascent.ing")
      session.https!
      session.get("/up")
      result = {
        environment: Rails.env,
        health_status: session.response.status,
        eager_load: Rails.application.config.eager_load,
        force_ssl: Rails.application.config.force_ssl,
        assume_ssl: Rails.application.config.assume_ssl,
        local_errors: Rails.application.config.consider_all_requests_local,
        cache_store: Rails.application.config.cache_store,
        queue_adapter: Rails.application.config.active_job.queue_adapter,
        storage: Rails.application.config.active_storage.service,
        mail_host: ActionMailer::Base.default_url_options,
        delivery_method: ActionMailer::Base.delivery_method,
        mail_key_configured: ActionMailer::Base.postshiba_settings[:api_key] == "staging-mail-key",
        databases: configurations.to_h { |configuration| [configuration.name, configuration.configuration_hash.slice(:adapter, :database, :migrations_paths)] },
        cache: Rails.application.config_for(:cache),
        queue: Rails.application.config_for(:queue),
        cable: Rails.application.config_for(:cable)
      }
      puts "STAGING_CONFIG:" + JSON.generate(result)
    RUBY
    output, status = Open3.capture2e(environment, RbConfig.ruby, "bin/rails", "runner", "-e", "staging", script,
      chdir: File.expand_path("../..", __dir__))
    expect(status.success?).to be(true), output
    result = output.lines.find { it.start_with?("STAGING_CONFIG:") }
    expect(result).not_to be_nil, output
    JSON.parse(result.delete_prefix("STAGING_CONFIG:"))
  end

  it "boots with production protections, staging email links, and all four database connections" do
    configuration = staging_configuration

    expect(configuration).to include(
      "environment" => "staging", "health_status" => 200, "eager_load" => true, "force_ssl" => true, "assume_ssl" => true,
      "local_errors" => false, "cache_store" => "solid_cache_store", "queue_adapter" => "solid_queue",
      "storage" => "local", "delivery_method" => "postshiba", "mail_key_configured" => true,
      "mail_host" => { "host" => "begin.ascent.ing", "protocol" => "https" }
    )
    expect(configuration.fetch("databases").keys).to contain_exactly("primary", "cache", "queue", "cable")
    configuration.fetch("databases").each do |name, database|
      expected_database = name == "primary" ? "ascent_staging" : "ascent_staging_#{name}"
      expect(database).to include("adapter" => "postgis", "database" => expected_database)
      expect(database.fetch("migrations_paths")).to eq("db/#{name}_migrate") unless name == "primary"
    end
    expect(configuration.fetch("cache")).to include("database" => "cache", "store_options" => include("namespace" => "staging"))
    expect(configuration.fetch("queue").fetch("workers")).not_to be_empty
    expect(configuration.fetch("cable")).to include("adapter" => "solid_cable", "connects_to" => { "database" => { "writing" => "cable" } })
  end

  it "uses APP_HOST for account links when the staging domain changes" do
    expect(staging_configuration(host: "preview.ascent.ing").fetch("mail_host"))
      .to eq("host" => "preview.ascent.ing", "protocol" => "https")
  end
end
