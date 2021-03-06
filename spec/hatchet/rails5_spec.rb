require_relative '../spec_helper'

describe "Rails 5" do
  it "works" do
    Hatchet::Runner.new("rails5").deploy do |app, heroku|
      expect(app.run("rails -v")).to match("")
    end
  end

  describe "active storage" do
    it "non-local storage warnings" do
      Hatchet::Runner.new("active_storage_non_local").deploy do |app, heroku|
        expect(app.output).to     match('binary dependencies required')
        expect(app.output).to_not match('config.active_storage.service')
        expect(app.output).to_not match(/\$ rails runner/)
      end
    end

    it "local storage warnings" do
      app = Hatchet::Runner.new(
        "active_storage_local",
        buildpacks: [
          "https://github.com/heroku/heroku-buildpack-activestorage-preview",
          Hatchet::App.default_buildpack
        ]
      )
      app.setup!
      app.set_config('HEROKU_DEBUG_RAILS_RUNNER' => 'true')
      app.deploy do |app, heroku|
        expect(app.output).to_not match('binary dependencies required')
        expect(app.output).to     match('config.active_storage.service')
        expect(app.output).to     match('config.assets.compile = true')
        expect(app.output).to     match(/\$ rails runner/)
      end
    end
  end

  it "blocks bads sprockets config with bad version" do
    Hatchet::Runner.new("sprockets_asset_compile_true", allow_failure: true).deploy do |app, heroku|
      expect(app.output).to match('A security vulnerability has been detected')
      expect(app.output).to match('version "3.7.2"')
    end
  end
end

describe "Rails 5.1" do
  it "works with webpacker + yarn (js friends)" do
    Hatchet::Runner.new("rails51_webpacker").deploy do |app, heroku|
      expect(app.output).to include("Installing yarn")
      expect(app.output).to include("yarn install")
      expect(app.run("rails -v")).to match("")
    end
  end
end
