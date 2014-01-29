require 'spec_helper'

describe GemPolish::CLI::Versioner do
  let(:versioner) { GemPolish::CLI::Versioner.new('') }
  let(:version_file) do
    <<-FILE
    module Dummy
      VERSION = "2.1.3"
    end
    FILE
  end
  let(:version_hash) do
    {
      'major' => 2,
      'minor' => 1,
      'revision' => 3,
    }
  end

  describe "#extract_from_version_file" do
    it "returns current version as a hash" do
      versioner.stub(:file_contents) { version_file }
      versioner.extract_from_version_file.should == version_hash
    end
  end

  describe "#to_version" do
    it "converts a given version hash to a string" do
      versioner.to_version(version_hash).should == "2.1.3"
    end

    it "returns current version when no version hash is given" do
      versioner.stub(:file_contents) { version_file }
      versioner.instance_variable_set(:@version, versioner.extract_from_version_file)
      versioner.to_version.should == "2.1.3"
    end
  end

  describe "#update_version" do
    before(:each) do
      versioner.stub(:file_contents) { version_file }
      versioner.instance_variable_set(:@version, versioner.extract_from_version_file)
    end

    describe "returns an updated version hash for the given bumper" do
      it "bumps revision" do
        res = {
          'major' => 2,
          'minor' => 1,
          'revision' => 4,
        }
        versioner.update_version('revision').should == res
      end

      it "bumps minor version" do
        res = {
          'major' => 2,
          'minor' => 2,
          'revision' => 0,
        }
        versioner.update_version('minor').should == res
      end

      it "bumps major version" do
        res = {
          'major' => 3,
          'minor' => 0,
          'revision' => 0,
        }
        versioner.update_version('major').should == res
      end
    end
  end

  describe "#commit_version_bump" do
    it "raises an error when staged files are present" do
      versioner.stub(:staged_files_present?) { true }
      expect { versioner.commit_version_bump('') }.to raise_error StandardError, /aborted/
    end
  end
end
