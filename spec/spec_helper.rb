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
