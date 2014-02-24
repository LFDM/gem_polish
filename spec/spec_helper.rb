$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gem_polish'

TESTFILES_DIR = File.expand_path("../helpers/testfiles", __FILE__)

def testfile(name)
  "#{TESTFILES_DIR}/#{name}"
end

def read_testfile(name)
  File.read(testfile(name))
end

def create_testfile(name)
  `touch #{testfile(name)}`
end

def remove_testfiles
  Dir.chdir(TESTFILES_DIR) do
    Dir["*"].each { |f| File.delete(f) }
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
