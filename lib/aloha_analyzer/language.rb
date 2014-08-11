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
        format(LANGUAGES['languages'][abbreviation], :twitter)
      else
        format(LANGUAGES['languages']['other'], :twitter)
      end
    end

    def self.format(language, network)
      {
        'abbreviation' => language['abbreviation'],
        'name'         => language['name'],
        'population'   => language["#{network}_population"],
        'countries'    => language['countries'],
        'greeting'     => language['greeting']
      }
    end
  end
end
