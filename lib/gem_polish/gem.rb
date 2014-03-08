module GemPolish
  class Gem < Thor
    include Thor::Actions

    require 'gem_polish/cli/gem_manipulator'

    namespace :gem

    desc 'add', 'adds one or several gems to your Gemfile'
    def add(*gems)
      gem_action(:add, gems, options)
    end

    desc 'delete', 'deletes one or several gems from your Gemfile'
    def delete(*gems)
      gem_action(:delete, gems, options)
    end

    desc 'update', 'updates one specific gem from your Gemfile'
    def update(*gems)
      gem_action(:update, gems, options)
    end

    no_commands do
      def gem_action(name, gems, options)
        inside('.') do
          CLI::GemManipulator.new(self).send(name, gems, options)
        end
      end
    end
  end
end
