require 'beaker-rspec'
require 'tmpdir'
require 'yaml'
require 'simp/beaker_helpers'

# rubocop:disable Style/MixinUsage
include Simp::BeakerHelpers
# rubocop:enable Style/MixinUsage

# Note that ISO integration tests don't need to run install_puppet

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
