module GemPolish
  class CLI::Versioner
    def initialize(thor)
      @thor = thor
      @version = extract_from_version_file
    end

    def extract_from_version_file
      file_contents.match(regexp)
      numbers = $1.split('.').map(&:to_i)
      Hash[%w{ major minor revision}.zip(numbers)]
    end

    def to_version(hsh = @version)
      hsh.values.join('.')
    end

    def substitute_version(v)
      version = v.kind_of?(String) ? v : to_version(v)
      @thor.gsub_file(file, regexp, insertion(version))
      @thor.say_status(:bumped_version, "#{to_version} => #{version}")
    end

    def update_version(bumper)
      set_back = false
      @version.each_with_object({}) do |(level, number), h|
        nl = if set_back
               0
             else
               if level == bumper
                 set_back = true
                 number + 1
               else
                 number
               end
             end
        h[level] = nl
      end
    end

    def commit_version_bump(message)
      if staged_files_present?
        raise StandardError.new, "Commit aborted: Staged files present"
      else
        `git add #{file}`
        `git commit -m "#{message}"`
        sha = `git rev-parse --short HEAD`.chomp
        @thor.say_status(:commited, %{#{sha} "#{message}"})
      end
    end

    def release
      `rake release`
      @thor.say_status(:released, '')
    end

    private

    def gem_name
      File.basename(Dir.pwd)
    end

    def file_contents
      File.read(file)
    end

    def file
      "lib/#{gem_name.sub('-', '/')}/version.rb"
    end

    def regexp
      /VERSION = "(.*?)"/
    end

    def insertion(version)
      %{VERSION = "#{version}"}
    end

    def staged_files_present?
      system('git status --porcelain | grep -o "^\w" >/dev/null')
    end
  end
end
