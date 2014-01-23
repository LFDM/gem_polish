require 'thor'
require 'yaml'

class CLI < Thor
  include Thor::Actions
    def self.default_badges
      %i{ badge_fury gemnasium travis coveralls code_climate }
    end

  desc "polish", "polishes your gem"
  method_option :badges, type: :array, lazy_default: default_badges, aliases: '-b'
  method_option :git_user_name, type: :string, aliases: '-g'
  method_option :description, aliases: '-d'
  method_option :coverage, aliases: '-c'
  method_option :rspec_configuration, aliases: '-r'
  method_option :no_default
  def polish
    default = options[:no_default] ? {} : def_conf

    git_user_name = extract_git_user(options)
    badges = parse_opt(:badges, options, default)

    description = options[:description]

    puts options
    puts default
    exit
    insert_badges(badges, git_user_name, gem_name) if badges
    insert_description(description) if description
    insert_coveralls if parse_opt(:coverage, options, default)
    insert_rspec_conf if parse_opt(:rspec_configuration, options, default)
  end

  no_commands do
    def parse_opt(opt, opts, default)
      opts[opts] || default[opt]
    end

    def extract_git_user(options)
     user = options[:git_user_name] || `git config user.name`.chomp
     user.empty? ? "TODO: Write your name" : user
    end

    def insert_description(description)
      gsub_file(gemspec, /TODO:.*summary.*(?=})/, description)
      gsub_file(readme, /TODO:.*gem description/, description)
    end

    BADGE_NAMES = {
      'badge_fury' => 'Version',
      'gemnasium' => 'Dependencies',
      'travis' => 'Build Status',
      'coveralls' => 'Coverage',
      'code_climate' => 'Code Climate'
    }

    def insert_badges(badges, user, gem)
      insert_into_file(readme, after: /^#\s.*\n/, force: false) do
        "\n#{badges.map { |badge| badge_link(badge, user, gem) }.join("\n")}\n"
      end
    end

    def badge_link(badge, user, gem)
      path = "http://allthebadges.io/#{user}/#{gem}/#{badge}"
      "[![#{BADGE_NAMES[badge]}](#{path}.png)](#{path})"
    end

    def insert_coveralls
      prepend_file(spec_helper, read_template(:coveralls) + "\n")
      add_dev_dependency('simplecov', '0.7')
      append_file(gemfile, %{gem 'coveralls', require: false})
    end

    def insert_rspec_conf
      append_file(spec_helper, "\n" + read_template(:rspec_configuration))
    end

    def def_conf
      conf_file = "#{ENV['HOME']}/.gem_polish.yml"
      conf = File.exists?(conf_file) ? YAML.load(File.read(conf_file)) : {}
      conf.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
    end

    def gem_name
      File.basename(Dir.pwd)
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

    def read_template(name)
      File.read("#{Dir.pwd}/lib/templates/#{name}.template")
    end

    def add_dev_dependency(gem, version = nil)
      gs = "#{Dir.pwd}/#{gemspec}"
      total_size = File.size(gs)
      pos_before_end = total_size - 4
      insertion = %{  spec.add_development_dependency "#{gem}"}
      insertion << %{, "~> #{version}"} if version

      File.open(gs, 'r+') do |file|
        file.seek(pos_before_end, IO::SEEK_SET)
        file.puts(insertion)
        file.puts('end')
      end
    end
  end
end

