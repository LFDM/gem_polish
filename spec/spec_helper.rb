$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gem_polish'

TESTFILES_DIR = "helpers/testfiles"

def testfile(name)
  File.expand_path("#{TESTFILES_DIR}/#{name}", __FILE__)
end

def read_testfile(name)
  File.read(testfile(name))
end

def create_testfile(name)
  `touch #{testfile(name)}`
end

def remove_testfiles(name)
  `rm #{TESTFILES_DIR}/*`
end

