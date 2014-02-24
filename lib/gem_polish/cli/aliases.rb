module GemPolish
  class CLI::Aliases
    def initialize(thor)
      @thor = thor
    end

    def create(options)
      destination = options[:destination]
      prefix = options[:prefix] || 'gp'
      @thor.append_to_file(destination) do
        ['', header_line, aliases(prefix)].join("\n")
      end
    end

    ALIASES = {
      'h' => 'help',
      'p' => 'polish',
      'v' => 'version',
      'ga' => 'gem add',
      'gd' => 'gem delete',
      'gu' => 'gem update',
    }

    def aliases(prefix)
      ALIASES.map do |al, command|
        "alias #{prefix}#{al}='gem_polish #{command}'"
      end.join("\n")
    end

    def header_line
      "# gem_polish aliases"
    end
  end
end
