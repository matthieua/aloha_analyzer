module AlohaAnalyzer
  class Base
    attr_reader :language, :analysis

    def initialize(options)
      @language = clean_language(options['language'].downcase)
      @analysis = (options['analysis'] || boilerplate).clone
      @options  = options
    end

    def analyze(users)
      clean_users(users).each do |user|
        if user[language_key] == @language
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

    def boilerplate
      {
        'account_language' => {
          'count'    => 0,
          'language' => Language.find_by_abbreviation(@language, network_name),
          'users'    => []
        },
        'foreign_languages_count' => 0,
        'count'                   => 0,
        'foreign_languages'       => {}
      }
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
        if Language.aliases.keys.include?(user[language_key].downcase)
          user[language_key] = Language.aliases[user[language_key].downcase]
        end
        user
      end
    end

    def network_name
      self.class.network_name
    end

    def language_key
      self.class.language_key
    end

    def too_many_users?(users)
      if @options['max_users'] && users.size >= @options['max_users']
        true
      else
        false
      end
    end

    def add_account_language_user(user)
      unless too_many_users?(@analysis['account_language']['users'])
        @analysis['account_language']['users'].push(user)
      end
    end

    def add_foreign_language_user(user)
      abbreviation = Language.find_by_abbreviation(user[language_key], network_name)['abbreviation']
      prepare_foreign_language(abbreviation)
      @analysis['foreign_languages'][abbreviation]['count'] += 1
      unless too_many_users?(@analysis['foreign_languages'][abbreviation]['users'])
        @analysis['foreign_languages'][abbreviation]['users'].push(user)
      end
    end

    def prepare_foreign_language(abbreviation)
      if @analysis['foreign_languages'][abbreviation].nil?
        @analysis['foreign_languages'][abbreviation] = {
          'count'    => 0,
          'language' => Language.find_by_abbreviation(abbreviation, network_name),
          'users'    => []
        }
      end
    end
  end
end
