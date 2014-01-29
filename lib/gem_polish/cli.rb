require 'thor'
require 'yaml'

module GemPolish
  class CLI < Thor

    require 'gem_polish/cli/polisher'
    require 'gem_polish/cli/versioner'
    include Thor::Actions

    desc "polish", "Polishes your gem skeleton"
    method_option :badges, type: :array, aliases: '-b',
      desc: 'Adds badges to your README. Takes one or more of: badge_fury, gemnasium, travis, coveralls and code_climate'
    method_option :git_user, type: :string, aliases: '-g',
      desc: 'Git user to be used for badge links. Defaults to your .gitconfig information'
    method_option :description, aliases: '-d',
      desc: 'Adds a descriptopn to the gemspec and the README'
    method_option :coverage, aliases: '-c',
      desc: 'Adds coveralls coverage'
    method_option :rspec_conf, aliases: '-r',
      desc: 'Adds additional rspec configuration'
    method_option :travis, type: :array, aliases: '-t',
      desc: 'Adds ruby versions to travis'
    method_option :no_default, aliases: '-n',
      desc: 'Bypasses ~/.gem_polish.yml. Defaults to false'
    def polish(name = '.')
      inside name do
        p = Polisher.new(options, self)
        p.insert_description
        p.insert_badges
        p.insert_coveralls
        p.insert_rspec_conf
        p.insert_travis
      end
    end

    desc 'version OPTION', 'Reads and writes the version file of your gem'
    method_option :read, type: :boolean, aliases: '-r',
      desc: 'Print current version number'
    method_option :bump, aliases: '-b', lazy_default: 'revision',
      desc: 'Bumps the version number (revision [default], minor or major)'
    method_option :version, aliases: '-v',
      desc: 'Specify the new version number directly'
    method_option :commit, aliases: '-c', lazy_default: 'Bump version',
      desc: 'Creates a git commit of a bump, takes a message, defaults to "Bump version"'
    def version(name = '.')
      inside name do
        return help(:version) if options.empty?
        v = Versioner.new(self)

        if specified_version = options[:version]
          v.substitute_version(specified_version)
        elsif options[:read]
          puts v.to_version
        elsif bump = options[:bump]
          updated = v.update_version(bump)
          v.substitute_version(updated)
          if message = options[:commit]
            v.commit_version_bump(message)
          end
        end
      end
    end
  end
end

