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
      languages.each do |language_key, count|
        if Language.aliases.keys.include?(language_key.downcase)
          if languages[Language.aliases[language_key.downcase]]
            languages[Language.aliases[language_key.downcase]] = languages[Language.aliases[language_key.downcase]] + count
            languages.delete language_key
          else
            languages[Language.aliases[language_key.downcase]] = languages.delete language_key
          end
        end
      end
    end
  end
end

