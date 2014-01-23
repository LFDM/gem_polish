require 'thor'

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
  def polish
    git_user_name = extract_git_user(options)
    badges = options[:badges]
    description = options[:description]

    insert_badges(badges, git_user_name, gem_name) if badges
    insert_description(description) if description
    insert_coveralls if options[:coverage]
  end

  no_commands do
    def gem_name
      File.basename(Dir.pwd)
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
      badge_fury: 'Version',
      gemnasium: 'Dependencies',
      travis: 'Build Status',
      coveralls: 'Coverage',
      code_climate: 'Code Climate'
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

