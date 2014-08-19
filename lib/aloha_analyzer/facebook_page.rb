module AlohaAnalyzer
  class FacebookPage < Base
    def self.network_name
      'facebook'
    end

    def analyze(languages)
      clean_languages(languages).each do |language_key, count|
        if language_key == @language
          @analysis['account_language']['count'] += count
        else
          add_foreign_language_user(language_key, count)
          @analysis['foreign_languages_count'] += count
        end
        @analysis['count'] += count
      end
      @analysis
    end

    def add_foreign_language_user(abbreviation, count)
      prepare_foreign_language(abbreviation)
      @analysis['foreign_languages'][abbreviation]['count'] += count
    end

    def clean_languages(languages)
      Hash.new.tap do |cleaned_languages|
        languages.each do |language_key, count|
          abbreviation = Language.aliases[language_key.downcase]
          abbreviation = Language.find_by_abbreviation(language_key.downcase, network_name)['abbreviation'] if abbreviation.nil?

          if cleaned_languages[abbreviation]
            cleaned_languages[abbreviation] += count
          else
            cleaned_languages[abbreviation] = count
          end
        end
      end
    end
  end
end

