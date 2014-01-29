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
      if description
        @thor.gsub_file(gemspec, /TODO:.*summary.*(?=})/, description)
        @thor.gsub_file(readme, /TODO:.*gem description/, description)
      end
    end

    def insert_badges
      if badges
        @thor.insert_into_file(readme, after: /^#\s.*\n/, force: false) { badge_links }
      end
    end

    def insert_coveralls
      if parse_opt(:coveralls)
        @thor.prepend_file(spec_helper, template(:coveralls) + "\n")
        add_dev_dependency('simplecov', '0.7')
        @thor.append_file(gemfile, %{gem 'coveralls', require: false})
      end
    end

    def insert_rspec_conf
      if parse_opt(:rspec_conf)
        @thor.append_file(spec_helper, "\n" + template(:rspec_configuration))
      end
    end

    def insert_travis
      if t = parse_opt(:travis)
        @thor.say_status :rewrite, relative_destination(travis)
        File.write(travis, YAML.dump(travis_content(t)))
      end
    end

    def git_user
      user = @options[:git_user] || read_from_git_config
      user.empty? ? "TODO: Write your name" : user
    end

    private

    def description
      @description ||= @options[:description]
    end

    BADGE_NAMES = {
      'badge_fury' => 'Version',
      'gemnasium' => 'Dependencies',
      'travis' => 'Build Status',
      'coveralls' => 'Coverage',
      'code_climate' => 'Code Climate'
    }

    def badges
      @badges ||= parse_opt(:badges)
    end

    def badge_links
      "\n#{badges.map { |badge| badge_link(badge) }.join("\n")}\n"
    end

    def badge_link(badge)
      path = "http://allthebadges.io/#{git_user}/#{gem_name}/#{badge}"
      "[![#{BADGE_NAMES[badge]}](#{path}.png)](#{path})"
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

    def add_dev_dependency(gem, version = nil)
      total_size = File.size(gemspec)
      pos_before_end = total_size - 4
      insertion = %{  spec.add_development_dependency "#{gem}"}
      return if File.read(gemspec).match(/#{insertion}/)
      insertion << %{, "~> #{version}"} if version

      @thor.say_status :append, relative_destination(gemspec)
      File.open(gemspec, 'r+') do |file|
        file.seek(pos_before_end, IO::SEEK_SET)
        file.puts(insertion)
        file.puts('end')
      end
    end

    def travis_content(opts)
      c = { 'language' => 'ruby'}
      c.merge((opts.is_a?(Hash) ? opts : { 'rvm' => opts }))
    end

    def relative_destination(dest)
      d = File.expand_path(dest, @thor.destination_root)
      @thor.relative_to_original_destination_root(d)
    end

    TEMPLATE_DIR = File.expand_path('../../../templates', __FILE__)
    def template(name)
      File.read("#{TEMPLATE_DIR}/#{name}.template")
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
