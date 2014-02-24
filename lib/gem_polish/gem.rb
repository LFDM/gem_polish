module GemPolish
  class Gem < Thor
    require 'gem_polish/cli/gem_manipulator'
    namespace :gem

    desc 'add', 'adds one or several gems to your Gemfile'
    def add(*gems)
      action(:add, gems, options)
    end

    desc 'delete', 'deletes one or several gems from your Gemfile'
    def delete(*gems)
      action(:delete, gems, options)
    end

    desc 'update', 'updates one specific gem from your Gemfile'
    def update(*gems)
      action(:update, gems, options)
    end

    no_commands do
      def action(name, options)
        inside('.') do
          GemManipulator.new(self).send(name, options)
        end
      end
    end
  end
end
