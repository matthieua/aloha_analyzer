module AlohaAnalyzer
  class User

    attr_reader :language

    def initialize(language, users, options = {})
      @language    = language.downcase
      @users       = users
      @users_count = users.size
      @options     = options
      @analysis    = {}

      clean_language!
      clean_users_languages!
    end

    def analyze
      prepare!
      @users.each do |user|
        if user['lang'] == @language
          add_account_language_user(user)
          @analysis[:account_language][:count] += 1
        else
          add_foreign_language_user(user)
          @analysis[:foreign_languages_count] += 1
        end
        @analysis[:count] += 1
      end
      @analysis
    end

    private

    def add_account_language_user(user)
      unless too_many_users?(@analysis[:account_language][:users])
        @analysis[:account_language][:users].push(user)
      end
    end

    def add_foreign_language_user(user)
      prepare_foreign_language(user['lang'])
      @analysis[:foreign_languages][user['lang']][:count] += 1
      unless too_many_users?(@analysis[:foreign_languages][user['lang']][:users])
        @analysis[:foreign_languages][user['lang']][:users].push(user)
      end
    end

    def prepare_foreign_language(abbreviation)
      if @analysis[:foreign_languages][abbreviation].nil?
        @analysis[:foreign_languages][abbreviation] = {
          :count    => 0,
          :language => Language.find_by_abbreviation(abbreviation),
          :users    => []
        }
      end
    end

    def prepare!
      @analysis[:account_language] = {
        count:    0,
        language: Language.find_by_abbreviation(@language),
        users:    []
      }
      @analysis[:foreign_languages_count] = 0
      @analysis[:count]                   = 0
      @analysis[:foreign_languages]       = Hash.new
    end

    def too_many_users?(users)
      if @options[:user_limit_per_language] && users.size >= @options[:user_limit_per_language]
        true
      else
        false
      end
    end

    def clean_language!
      if Language.aliases.keys.include?(@language)
        @language = Language.aliases[@language]
      end
    end

    def clean_users_languages!
      @users.map! do |user|
        if Language.aliases.keys.include?(user['lang'].downcase)
          user['lang'] = Language.aliases[user['lang'].downcase]
        end
        user
      end
    end
  end
end
