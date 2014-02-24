module GemPolish
  class CLI::GemManipulator
    def initialize(thor)
      @thor = thor
    end

    def add(gems, options = {})
      gems = Array(gems)
      if gems.one?
        @thor.append_to_file(gemfile, new_gem(gems.first, options))
      end
    end

    private

    def new_gem(gem, options)
      attributes = %i{ version path }.map do |e|
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

    def gemfile
      "Gemfile"
    end
  end
end
