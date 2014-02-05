module Aloha
  class Analyzer
    attr_reader :username, :cursor, :languages
    def initialize(username, options = {})
      @username    = username
      @cursor      = options[:cursor] || -1
      @languages   = options[:languages] || Hash.new(0)
      @credentials = options[:credentials]
    end

    def count
      counter = 0
      @languages.each do |_, language_count|
        counter += language_count
      end
      counter
    end

    def calculate!
      response = client.followers(@username, request_options).to_h
      response[:users].each do |follower|
        increment user[:follower]
      end
      @cursor = response[:next_cursor]
    end

    private

    def request_options
      {
        count:       200,
        skip_status: false,
        cursor:      @cursor
      }
    end

    def client
      @client ||= ::Twitter::REST::Client.new do |config|
        config.consumer_key        = credentials['consumer_key']
        config.consumer_secret     = credentials['consumer_secret']
        config.access_token        = credentials['access_token']
        config.access_token_secret = credentials['access_token_secret']
      end
    end

    def increment(language)
      @languages[language] += 1
    end
  end
end
