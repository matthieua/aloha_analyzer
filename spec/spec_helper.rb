require 'rubygems'
require 'debugger'
require 'bundler/setup'

require 'twitter'
require 'aloha'
require 'webmock/rspec'


RSpec.configure do |config|
end

# stolen from the twitter gem
def stub_get(path)
  stub_request(:get, Twitter::REST::Client::ENDPOINT + path)
end
