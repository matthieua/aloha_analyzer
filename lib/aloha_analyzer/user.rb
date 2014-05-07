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
      {
        with_user_language:    with_user_language,
        without_user_language: without_user_language
      }
    end

    private

    def with_user_language
      @with_user_language ||= Hash.new.tap do |languages|
        @users.each do |user|
          abbreviation = user['lang']
          if languages[abbreviation]
            languages[abbreviation]['count'] += 1
          else
            languages[abbreviation] = {
              'count'      => 1,
              'language'   => Language.find_by_abbreviation(abbreviation)
            }
          end
          languages[abbreviation]['percentage'] = ((100 / @users_count.to_f) * languages[abbreviation]['count']).round
        end
      end
    end

    def without_user_language
      @without_user_language ||= Hash.new.tap do |languages|
        @users.each do |user|
          abbreviation = user['lang']
          if abbreviation != @language
            if languages[abbreviation]
              languages[abbreviation]['count'] += 1
            else
              languages[abbreviation] = {
                'count'      => 1,
                'language'   => Language.find_by_abbreviation(abbreviation)
              }
            end
            languages[abbreviation]['percentage'] = ((100 / users_total_without_user_language.to_f) * languages[abbreviation]['count']).round
          end
        end
      end
    end

    def users_total_without_user_language
      @users_total_without_user_language ||= @users_count - user_language_count
    end

    def user_language_count
      @user_language_count ||= if with_user_language[@language]
        with_user_language[@language]['count']
      else
        0
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
