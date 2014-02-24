require 'spec_helper'

describe GemPolish::CLI::GemManipulator do
  let(:cli) do
    Class.new(Thor) do
      include Thor::Actions
    end.new
  end

  let(:gem_manipulator) do
    gm = GemPolish::CLI::GemManipulator.new(cli)
    gm.stub(gemfile: testfile('Gemfile'))
    gm
  end

  before :all do
    string_io = StringIO.new
    @stdout = $stdout
    $stdout = string_io
  end

  before :each do
    create_testfile('Gemfile')
  end

  def gemfile
    read_testfile('Gemfile')
  end

  describe "#add" do
    context "with a single gem" do
      it "adds a gem to the Gemfile" do
        gem_manipulator.add('gp')
        read_testfile('Gemfile').should =~ /gem 'gp'/
      end

      context "with options" do
        it "can specify a version" do
          gem_manipulator.add('gp', version: '1.7')
          gemfile.should =~ /gem 'gp', '~> 1\.7'/
        end

        it "can specify a local path" do
          gem_manipulator.add('gp', path: '/home/code/gp')
          gemfile.should =~ /gem 'gp', path: '\/home\/code\/gp'/
        end

        it "can specify a git path - only the repository needs to be given" do
          gem_manipulator.add('gp', github: 'LFDM/gp')
          gemfile.should =~ /gem 'gp', git: 'git@github\.com:LFDM\/gp\.git'/
        end

        it "can specify the name to require" do
          gem_manipulator.add('gp', require: 'pg')
          gemfile.should =~ /gem 'gp', require: 'pg'/
        end

        it "can specify a plaform" do
          gem_manipulator.add('gp', platform: 'jruby')
          gemfile.should =~ /gem 'gp', platform: :jruby/
        end

        it "can specify a group" do
          gem_manipulator.add('gp', group: 'assets')
          gemfile.should =~ /gem 'gp', group: :assets/
        end

        it "takes multiple options" do
          gem_manipulator.add('gp', platform: 'jruby', version: '1.0')
          gemfile.should =~ /gem 'gp', '~> 1\.0', platform: :jruby/
        end
      end
    end

    context "with multiple gems" do
      it "adds multiple gems at once" do
        gem_manipulator.add(%w{ gp pg })
        gemfile.should =~ /gem 'gp'\ngem 'pg'/
      end

      context "with options" do
        it "places gems in ruby blocks" do
          gem_manipulator.add(%w{ gp pg }, platform: 'jruby')
          gemfile.should =~ /platform :jruby do\n  gem 'gp'\n  gem 'pg'\nend/
        end

        it "takes multiple blocks as well (group and platform)" do
          gem_manipulator.add(%w{ gp pg }, group: 'test', platform: 'jruby')
          gemfile.should =~ /group :test do\n  platform :jruby do\n    gem 'gp'\n    gem 'pg'\n  end\nend/
        end
      end
    end
  end

  after :all do
    $stdout = @stdout
  end

  after :each do
    remove_testfiles
  end
end
