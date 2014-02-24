module GemPolish
  class Gem < Thor
    namespace :gem

    desc 'add', 'adds one or several gems to your Gemfile'
    def add(*var)
    end

    desc 'delete', 'deletes one or several gems from your Gemfile'
    def delete(var)
    end

    desc 'update', 'updates one specific gem from your Gemfile'
    def update(var)
    end
  end
end
