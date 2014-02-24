require 'spec_helper'

describe GemPolish::CLI::Aliases do
  let(:cli) do
    Class.new(Thor) do
      include Thor::Actions
    end.new
  end

  let(:aliases) { GemPolish::CLI::Aliases.new(cli) }

  before :all do
    string_io = StringIO.new
    @stdout = $stdout
    $stdout = string_io

    create_testfile('zshrc')
  end

  describe "#create" do
    it "creates aliases in a given destination" do
      aliases.create(destination: testfile('zshrc'))
      file = read_testfile('zshrc')
      file.should_not be_empty
    end
  end

  describe "#aliases" do
    it "returns gem_polish aliases with a given prefix" do
      aliases.aliases('gp').should =~ /alias gph='gem_polish help'/
    end
  end

  after :all do
    $stdout = @stdout
    remove_testfiles
  end
end
