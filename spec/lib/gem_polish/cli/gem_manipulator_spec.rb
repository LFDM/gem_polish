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
    context "with a single gem requested" do
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
