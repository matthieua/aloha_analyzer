module Aloha
  class Follower
    attr_reader :username, :cursor, :languages
    def initialize(username, options = {})
      @username    = username
      @cursor      = options[:cursor] || -1
      @languages   = options[:languages] || Hash.new(0)
      @credentials = options[:credentials]
    end

    def calculate!
      while true
        hashie = client.followers(@username, count: 200, skip_status: false, :cursor => @cursor).to_h
        hashie[:users].each do |user|
          increment user[:lang]
        end
        @cursor = hashie[:next_cursor]
      end
    rescue Twitter::Error::TooManyRequests => error
    end

    def to_h
      {
        username:  username,
        languages: languages,
        count:     total_count,
        cursor:    cursor
      }
    end

    private

    def client
      @client ||= ::Twitter::REST::Client.new do |config|
        config.consumer_key        = credentials['consumer_key']
        config.consumer_secret     = credentials['consumer_secret']
        config.access_token        = credentials['access_token']
        config.access_token_secret = credentials['access_token_secret']
      end
    end

    def total_count
      counter = 0
      @languages.each do |_, language_count|
        counter += language_count
      end
      counter
    end

    def increment(language)
      @languages[language] += 1
    end
  end
end
