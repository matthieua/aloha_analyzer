require 'yaml'

module AlohaAnalyzer
  class Language
    LANGUAGES        = YAML::load(File.open('config/language.yml'))
    TOTAL_POPULATION = 750_000_000

    def self.all
      LANGUAGES
    end

    def self.total
      TOTAL_POPULATION
    end

    def self.aliases
      {
        'en-gb' => 'en',
        'zh-cb' => 'zh',
        'zh-tw' => 'zh'
      }
    end

    def self.find_by_abbreviation(abbreviation)
      all.each do |language|
        return language if language['abbreviation'] == abbreviation
      end
      nil
    end
  end
end
