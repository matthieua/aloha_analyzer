module AlohaAnalyzer
  class Follower
    attr_reader :screen_name, :cursor, :languages

    def initialize(screen_name, options = {})
      @screen_name = screen_name
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

    def analyze!
      response = client.followers(@screen_name, request_options).to_h
      response[:users].each do |follower|
        increment follower[:lang]
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
      @client ||= ::Twitter::REST::Client.new(
        consumer_key:         @credentials[:consumer_key],
        consumer_secret:      @credentials[:consumer_secret],
        access_token:         @credentials[:access_token],
        access_token_secret:  @credentials[:access_token_secret]
      )
    end

    def increment(language)
      @languages[language] = @languages[language] || 0
      @languages[language] += 1
    end
  end
end
