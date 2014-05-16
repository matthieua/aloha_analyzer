module AlohaAnalyzer
  class User

    attr_reader :language, :analysis

    def initialize(language, users, options = {}, analysis = nil)
      @language    = clean_language(language.downcase)
      @users       = clean_users(users)
      @users_count = users.size
      @options     = options
      @analysis    = analysis || boilerplate
    end

    def analyze
      @users.each do |user|
        if user['lang'] == @language
          add_account_language_user(user)
          @analysis['account_language']['count'] += 1
        else
          add_foreign_language_user(user)
          @analysis['foreign_languages_count'] += 1
        end
        @analysis['count'] += 1
      end
      @analysis
    end

    private

    def add_account_language_user(user)
      unless too_many_users?(@analysis['account_language']['users'])
        @analysis['account_language']['users'].push(user)
      end
    end

    def add_foreign_language_user(user)
      prepare_foreign_language(user['lang'])
      @analysis['foreign_languages'][user['lang']]['count'] += 1
      unless too_many_users?(@analysis['foreign_languages'][user['lang']]['users'])
        @analysis['foreign_languages'][user['lang']]['users'].push(user)
      end
    end

    def prepare_foreign_language(abbreviation)
      if @analysis['foreign_languages'][abbreviation].nil?
        @analysis['foreign_languages'][abbreviation] = {
          'count'    => 0,
          'language' => Language.find_by_abbreviation(abbreviation),
          'users'    => []
        }
      end
    end

    def boilerplate
      {
        'account_language' => {
          'count'    => 0,
          'language' => Language.find_by_abbreviation(@language),
          'users'    => []
        },
        'foreign_languages_count' => 0,
        'count'                   => 0,
        'foreign_languages'       => {}
      }
    end

    def too_many_users?(users)
      if @options['user_limit_per_language'] && users.size >= @options['user_limit_per_language']
        true
      else
        false
      end
    end

    def clean_language(language)
      if Language.aliases.keys.include?(language)
        Language.aliases[language]
      else
        language
      end
    end

    def clean_users(users)
      users.map do |user|
        if Language.aliases.keys.include?(user['lang'].downcase)
          user['lang'] = Language.aliases[user['lang'].downcase]
        end
        user
      end
    end
  end
end
