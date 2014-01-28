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
    private

    def gem_name
      File.basename(Dir.pwd)
    end

    def file_contents
      File.read(file)
    end

    def file
      "lib/#{gem_name}/version.rb"
    end

    def regexp
      /VERSION = "(.*?)"/
    end

    def insertion(version)
      %{VERSION = "#{version}"}
    end
  end
end