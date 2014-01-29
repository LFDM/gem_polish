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

    def insert_badges
      return unless badges

      @thor.insert_into_file(readme, after: /^#\s.*\n/, force: false) { badge_string }
    end

    def git_user
      user = @options[:git_user] || read_from_git_config
      user.empty? ? "TODO: Write your name" : user
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
      @description ||= @options[:description]
    end

    def badges
      @badges ||= parse_opt(:badges)
    end

    def badges_string
      "\n#{badges.map { |badge| badge_link(badge, git_user, gem_name) }.join("\n")}\n"
    end

    def read_from_git_config
      # can it return nil?
      `git config user.name`.to_s.chomp
    end

    def parse_opt(opt)
      @options[opt] || @defaults[opt]
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
