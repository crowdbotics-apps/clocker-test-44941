# frozen_string_literal: true

# Needed to load gems from Gemfile
require "rubygems"
require "bundler/setup"

require "spaceship"
require "json"

# Constants
def bundle_ids
  ENV["BUNDLE_IDENTIFIERS"]
end

def itc_username
  ENV["ITC_USERNAME"]
end

def itc_password
  ENV["ITC_PASSWORD"]
end

def spaceship_connect_api_key_id
  ENV["SPACESHIP_CONNECT_API_KEY_ID"]
end

def spaceship_connect_api_issuer_id
  ENV["SPACESHIP_CONNECT_API_ISSUER_ID"]
end

def spaceship_connect_api_key
  ENV["SPACESHIP_CONNECT_API_KEY"]
end

def uses_app_store_connect_auth_token
  !spaceship_connect_api_key_id.nil? && !spaceship_connect_api_issuer_id.nil? && !spaceship_connect_api_key.nil?
end

def uses_app_store_connect_auth_credentials
  !uses_app_store_connect_auth_token && !itc_username.nil?
end

def itc_team_id_array
  # Split team_id
  ENV["ITC_TEAM_IDS"].to_s.split(",")
end

def number_of_builds
  (ENV["NUMBER_OF_BUILDS"] || 1).to_i
end


unless uses_app_store_connect_auth_token || uses_app_store_connect_auth_credentials
  puts "Couldn't find valid authentication token or credentials."
  exit
end


def get_app_version_from(bundle_ids)
    apps = Spaceship::ConnectAPI::App.all
    puts JSON.dump apps
end

if uses_app_store_connect_auth_token
  Spaceship::ConnectAPI.auth(key_id: spaceship_connect_api_key_id, issuer_id: spaceship_connect_api_issuer_id, key: spaceship_connect_api_key)
else
  Spaceship::ConnectAPI.login(itc_username, itc_password)
end

# All json data
versions = []

# Add for the team_ids
# Test if itc_team doesnt exists
if itc_team_id_array.length.zero?
  get_app_version_from(bundle_ids)
else
  itc_team_id_array.each do |itc_team_id|
    Spaceship::ConnectAPI.select_team(tunes_team_id: itc_team_id) if itc_team_id
    versions += get_app_version_from(bundle_ids)
  end
end
