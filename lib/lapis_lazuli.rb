#
# LapisLazuli
# https://github.com/spriteCloud/lapis-lazuli
#
# Copyright (c) 2013-2014 spriteCloud B.V. and other LapisLazuli contributors.
# All rights reserved.
#

begin
  require "simplecov"
  require "rubygems"
  spec = Gem::Specification.find_by_name("lapis_lazuli")
  gem_root = "#{spec.gem_dir}#{File::SEPARATOR}"
  coverage_root = "#{gem_root}lib"
  output_dir = "#{Dir.getwd}#{File::SEPARATOR}coverage"

  if ENV['COVERAGE']
    puts "Enabling code coverage for files under '#{coverage_root}';"
    puts "coverage reports get written to '#{output_dir}'."
    SimpleCov.start do
      root(coverage_root)
      coverage_dir(output_dir)
    end
  end
rescue LoadError
  # do nothing
end

require "lapis_lazuli/version"

require "lapis_lazuli/world/config"
require "lapis_lazuli/world/hooks"
require "lapis_lazuli/world/variable"
require "lapis_lazuli/world/error"
require "lapis_lazuli/world/annotate"
require "lapis_lazuli/world/logging"
require "lapis_lazuli/world/browser"
require "lapis_lazuli/world/api"
require "lapis_lazuli/generic/xpath"


module LapisLazuli
  ##
  # Includes all the functionality from the following modules.
  include LapisLazuli::WorldModule::Config
  include LapisLazuli::WorldModule::Hooks
  include LapisLazuli::WorldModule::Variable
  include LapisLazuli::WorldModule::Error
  include LapisLazuli::WorldModule::Annotate
  include LapisLazuli::WorldModule::Logging
  include LapisLazuli::WorldModule::Browser
  include LapisLazuli::WorldModule::API
  include LapisLazuli::GenericModule::XPath
end # module LapisLazuli
