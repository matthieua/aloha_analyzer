require 'yaml'

module AlohaAnalyzer
  class Language

    LANGUAGES        = YAML::load_file(File.join(File.dirname(__FILE__), 'yaml/language.yml'))
    TOTAL_POPULATION = 790000000

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
        'zh-tw' => 'zh',
        'ca'    => 'es',
        'xx-lc' => 'en',
        'gl'    => 'es',
        'eu'    => 'es'
      }
    end

    def self.find_by_abbreviation(abbreviation)
      all.each do |language|
        return language if language['abbreviation'] == abbreviation
      end
      raise "Could not find language abbreviation '#{abbreviation}'"
    end
  end
end
