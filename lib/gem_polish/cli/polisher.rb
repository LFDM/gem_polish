require 'yaml'

module GemPolish
  class CLI::Polisher
    def initialize(options, thor)
      @options = options
      @thor = thor
      @defaults = set_defaults
    end

    def set_defaults
      defaults_disabled? ? {} : read_from_conf_file
    end

    def insert_description
      return unless description

      @thor.gsub_file(gemspec, /TODO:.*summary.*(?=})/, description)
      @thor.gsub_file(readme, /TODO:.*gem description/, description)
    end

    private

    BADGE_NAMES = {
      'badge_fury' => 'Version',
      'gemnasium' => 'Dependencies',
      'travis' => 'Build Status',
      'coveralls' => 'Coverage',
      'code_climate' => 'Code Climate'
    }

    def description
      @options[:description]
    end

    def read_from_conf_file
      conf_file_present? ? load_conf_file : {}
    end

    def defaults_disabled?
      @options[:no_default]
    end

    def conf_file_present?
      File.exist?(conf_file)
    end

    def load_conf_file
      YAML.load(File.read(conf_file)).each_with_object({}) do |(k, v), h|
        h[k.to_sym] = v
      end
    end

    def conf_file
      "#{ENV['HOME']}/.gem_polish.yml"
    end

    def gem_name
      File.basename(Dir.pwd)
    end

    def travis
      ".travis.yml"
    end

    def spec_helper
      "spec/spec_helper.rb"
    end

    def gemspec
      "#{gem_name}.gemspec"
    end

    def gemfile
      "Gemfile"
    end

    def readme
      "README.md"
    end
  end
end
