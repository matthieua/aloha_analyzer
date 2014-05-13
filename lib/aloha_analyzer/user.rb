module AlohaAnalyzer
  class User

    attr_reader :language

    def initialize(language, users)
      @language    = language.downcase
      @users       = users
      @users_count = users.size
      clean_language!
      clean_users_languages!
    end

    def analyze
      boilerplate_analysis.tap do |analysys|
        @users.each do |user|
          abbreviation = user['lang']
          if abbreviation == @language
            analysys[:account_language][:count] += 1
            analysys[:account_language][:users].push user
          else
            if analysys[:non_account_languages][abbreviation]
              analysys[:non_account_languages][abbreviation][:count] += 1
              analysys[:non_account_languages][abbreviation][:users].push user
            else
              analysys[:non_account_languages][abbreviation] = {
                :count    => 1,
                :language => Language.find_by_abbreviation(abbreviation),
                :users    => [user]
              }
            end
            analysys[:non_account_languages_count] += 1
          end
          analysys[:count] += 1
        end
      end
    end


    private

    def boilerplate_analysis
      Hash.new.tap do |analysys|
        analysys[:account_language] = {
          count:    0,
          language: Language.find_by_abbreviation(@language),
          users: []
        }
        analysys[:non_account_languages_count] = 0
        analysys[:count]                   = 0
        analysys[:non_account_languages]       = Hash.new
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
