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
  def polish
    git_user_name = extract_git_user(options)
    badges = options[:badges]
    description = options[:description]

    insert_badges(badges, git_user_name, gem_name) if badges
    insert_description(description) if description
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
      gsub_file("#{gem_name}.gemspec", /TODO:.*summary.*(?=})/, description)
      gsub_file("README.md", /TODO:.*gem description/, description)
    end

    BADGE_NAMES = {
      badge_fury: 'Version',
      gemnasium: 'Dependencies',
      travis: 'Build Status',
      coveralls: 'Coverage',
      code_climate: 'Code Climate'
    }

    def insert_badges(badges, user, gem)
      insert_into_file('README.md', after: /^#\s.*\n/, force: false) do
        "\n#{badges.map { |badge| badge_link(badge, user, gem) }.join("\n")}\n"
      end
    end

    def badge_link(badge, user, gem)
      path = "http://allthebadges.io/#{user}/#{gem}/#{badge}"
      "[![#{BADGE_NAMES[badge]}](#{path}.png)](#{path})"
    end

  end
end

