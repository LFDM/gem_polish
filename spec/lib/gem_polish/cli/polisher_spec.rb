require 'spec_helper'

describe GemPolish::CLI::Polisher do
  let(:thor) do
    double(gsub_file: true, insert_into_file: true)
  end

  class GemPolish::CLI::Polisher
    # we need to override this, otherwise it really reads
    # the conf file
    def load_conf_file
      {}
    end
  end

  def new_polisher(options)
    GemPolish::CLI::Polisher.new(options, thor)
    # need to stub this, otherwise it really reads from the conf file
  end

  describe "#set_defaults" do
    it "returns empty if --no-default was passed" do
      polisher = new_polisher(no_default: true)
      polisher.set_defaults.should be_empty
    end

    it "returns empty when no conf file is present" do
      polisher = new_polisher({})
      polisher.stub(conf_file_present?: false)
      polisher.set_defaults.should be_empty
    end

    it "loads conf file when present" do
      polisher = new_polisher({})
      conf_file = { a: 1}
      polisher.stub(load_conf_file: conf_file)
      polisher.set_defaults.should == conf_file
    end
  end

  describe "#insert_description" do
    it "does nothing when no desciption was passed" do
      polisher = new_polisher({})
      thor.should_not receive(:gsub_file)
      polisher.insert_description.should be_nil
    end

    it "inserts description in gemspec and README" do
      polisher = new_polisher(description: 'test')
      thor.should receive(:gsub_file).twice
      polisher.insert_description
    end
  end

  describe "#git_user" do
    it "returns the provided git user name" do
      polisher = new_polisher(git_user: 'Tester')
      polisher.git_user.should == 'Tester'
    end

    it "tries to read from git_config when nothing was provided" do
      polisher = new_polisher({})
      polisher.stub(read_from_git_config: 'Gitter')
      polisher.git_user.should == 'Gitter'
    end

    it "returns a todo when there is no user in git config" do
      polisher = new_polisher({})
      polisher.stub(read_from_git_config: '')
      polisher.git_user.should =~ /TODO/
    end
  end

  describe "#insert_badges" do
    it "does nothing when no badges were passed" do
      polisher = new_polisher({})
      thor.should_not receive(:insert_into_file)
      polisher.insert_badges
    end

    it "inserts badges when badges are present" do
      polisher = new_polisher(badges: ['travis'])
      thor.should receive(:insert_into_file)
      polisher.insert_badges
    end
  end
end
