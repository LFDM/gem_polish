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
      indent = 0
      str = ''

      %i{ group platform }.each do |block|
        if var = options.delete(block)
          method = send(block, var).sub(':', '')
          str << "#{to_ws(indent)}#{method} do\n"
          indent += 2
        end
      end

      str << gems.map do |gem|
        "#{to_ws(indent)}#{new_gem(gem, options)}"
      end.join("\n")

      (indent / 2).times do
        indent -= 2
        str << "\n#{to_ws(indent)}end"
      end

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

    def to_ws(count)
      ' ' * count
    end
  end
end
