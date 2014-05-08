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
        languages['count']     = 0
        languages['languages'] = Hash.new

        @users.each do |user|
          abbreviation = user['lang']
          if languages['languages'][abbreviation]
            languages['languages'][abbreviation]['count'] += 1
            languages['languages'][abbreviation]['users'].push user
          else
            languages['languages'][abbreviation] = {
              'count'    => 1,
              'language' => Language.find_by_abbreviation(abbreviation),
              'users'    => [user]
            }
          end
          languages['languages'][abbreviation]['percentage'] = ((100 / @users_count.to_f) * languages['languages'][abbreviation]['count']).round(2)
          languages['count'] += 1
        end
      end
    end

    def without_user_language
      @without_user_language ||= Hash.new.tap do |languages|
        languages['count']     = 0
        languages['languages'] = Hash.new

        @users.each do |user|
          abbreviation = user['lang']
          if abbreviation != @language
            if languages['languages'][abbreviation]
              languages['languages'][abbreviation]['count'] += 1
              languages['languages'][abbreviation]['users'].push user
            else
              languages['languages'][abbreviation] = {
                'count'    => 1,
                'language' => Language.find_by_abbreviation(abbreviation),
                'users'    => [user]
              }
            end
            languages['languages'][abbreviation]['percentage'] = ((100 / users_total_without_user_language.to_f) * languages['languages'][abbreviation]['count']).round(2)
            languages['count'] += 1
          end
        end
      end
    end

    def users_total_without_user_language
      @users_total_without_user_language ||= @users_count - user_language_count
    end

    def user_language_count
      @user_language_count ||= if with_user_language['languages'][@language]
        with_user_language['languages'][@language]['count']
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
