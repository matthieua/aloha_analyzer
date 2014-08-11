require 'yaml'

module AlohaAnalyzer
  class Language

    LANGUAGES = YAML::load_file(File.join(File.dirname(__FILE__), 'yaml/languages.yml'))
    ALIASES   = YAML::load_file(File.join(File.dirname(__FILE__), 'yaml/aliases.yml'))

    def self.all
      LANGUAGES['languages']
    end

    def self.aliases
      ALIASES['aliases']
    end

    def self.find_by_abbreviation(abbreviation)
      if LANGUAGES['languages'][abbreviation]
        LANGUAGES['languages'][abbreviation]
      else
        LANGUAGES['languages']['other']
      end
    end
  end
end
