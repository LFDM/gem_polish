require 'spec_helper'

describe GemPolish::CLI::Polisher do
  let(:thor) do
    double(gsub_file: true)
  end

  def new_polisher(options)
    GemPolish::CLI::Polisher.new(options, thor)
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

    it
  end
end
