module GemPolish
  class CLI::GemManipulator
    def initialize(thor)
      @thor = thor
    end

    def add(gems, options = {})
      gems = Array(gems)
      if gems.one?
        append(new_gem(gems.first, options))
      else
        create_with_blocks(gems, options)
      end
    end

    private

    def append(string)
      @thor.append_to_file(gemfile, "\n#{string}")
    end

    def create_with_blocks(gems, options)
      str = gems.map do |gem|
        new_gem(gem, options)
      end.join("\n")
      append(str)
    end

    def new_gem(gem, options)
      attributes = %i{ version require platform group path github }.map do |e|
        if attr = options[e]
          send(e, attr)
        end
      end.compact
      attributes.unshift("gem '#{gem}'").join(', ')
    end

    def version(var)
      "'~> #{var}'"
    end

    def path(var)
      "path: '#{var}'"
    end

    def github(var)
      "git: 'git@github.com:#{var}.git'"
    end

    def require(var)
      "require: '#{var}'"
    end

    def platform(var)
      "platform: :#{var}"
    end

    def group(var)
      "group: :#{var}"
    end

    def gemfile
      "Gemfile"
    end
  end
end
