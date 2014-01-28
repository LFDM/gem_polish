require 'thor'
require 'yaml'

module GemPolish
  class CLI < Thor
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
        default = options.has_key?('no_default') ? {} : def_conf

        description = options[:description]
        git_user_name = extract_git_user(options)
        badges = parse_opt(:badges, options, default)
        travis_opts = parse_opt(:travis, options, default)

        insert_badges(badges, git_user_name, gem_name) if badges
        insert_description(description) if description
        insert_coveralls if parse_opt(:coverage, options, default)
        insert_rspec_conf if parse_opt(:rspec_conf, options, default)
        insert_travis(travis_opts) if travis_opts
      end
    end

    desc 'version', 'Reads and writes the version file of your gem'
    method_option :read, aliases: '-r',
      desc: 'Print current version number'
    method_option :bump, aliases: '-b', lazy_default: 'revision',
      desc: 'Bumps the version number (revision [default], minor or major)'
    method_option :version, aliases: '-v',
      desc: 'Specify the new version number directly'
    def version(name = '.')
      inside name do
        v = version_number

        if specified_version = options[:version]
          substitute_version(specified_version)
          exit
        end

        if options[:read]
          puts to_version(v)
          exit
        end

        updated = update_version(v, options[:bump])
        substitute_version(to_version(updated))
        say_status(:bumped_version, "#{to_version(v)} => #{to_version(updated)}")
      end
    end

    no_commands do
      def version_number
        File.read(version_file).match(version_regexp)
        numbers = $1.split('.').map(&:to_i)
        Hash[%w{ major minor revision}.zip(numbers)]
      end

      def update_version(version_number, bumper)
        set_back = false
        version_number.each_with_object({}) do |(level, number), h|
          if set_back
            h[level] = 0
          else
            if level == bumper
              set_back = true
              new_number = number + 1
              h[level] = new_number
            else
              h[level] = number
            end
          end
        end
      end

      def version_regexp
        /VERSION = "(.*?)"/
      end

      def substitute_version(version)
        gsub_file(version_file, version_regexp, version_insertion(version))
      end

      def version_insertion(version)
        %{VERSION = "#{version}"}
      end

      def to_version(hsh)
        hsh.values.join('.')
      end

      def version_file
        "lib/#{gem_name}/version.rb"
      end
    end

    no_commands do
      def parse_opt(opt, opts, default)
        opts[opt] || default[opt]
      end

      def extract_git_user(options)
       user = options[:git_user] || `git config user.name`.chomp
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

      def insert_travis(opts)
        say_status :rewrite, relative_destination(travis)
        File.write(travis, YAML.dump(travis_content(opts)))
      end

      def travis_content(opts)
        c = { 'language' => 'ruby'}
        c.merge((opts.is_a?(Hash) ? opts : { 'rvm' => opts }))
      end

      def relative_destination(dest)
        d = File.expand_path(dest, destination_root)
        relative_to_original_destination_root(d)
      end

      def def_conf
        conf_file = "#{ENV['HOME']}/.gem_polish.yml"
        conf = File.exists?(conf_file) ? YAML.load(File.read(conf_file)) : {}
        conf.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
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

      TEMPLATE_DIR = File.expand_path('../../templates', __FILE__)
      def read_template(name)
        File.read("#{TEMPLATE_DIR}/#{name}.template")
      end

      def add_dev_dependency(gem, version = nil)
        total_size = File.size(gemspec)
        pos_before_end = total_size - 4
        insertion = %{  spec.add_development_dependency "#{gem}"}
        return if File.read(gemspec).match(/#{insertion}/)
        insertion << %{, "~> #{version}"} if version

        say_status :append, relative_destination(gemspec)
        File.open(gemspec, 'r+') do |file|
          file.seek(pos_before_end, IO::SEEK_SET)
          file.puts(insertion)
          file.puts('end')
        end
      end
    end
  end
end

