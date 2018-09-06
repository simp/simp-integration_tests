require 'beaker-rspec'
require 'tmpdir'
require 'yaml'
require 'simp/beaker_helpers'
include Simp::BeakerHelpers

# Note that ISO integration tests don't need to run install_puppet

RSpec.configure do |c|
  # ensure that environment OS is ready on each host
  fix_errata_on hosts

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    begin
      # Install modules and dependencies from spec/fixtures/modules
      copy_fixture_modules_to( hosts )

    rescue StandardError, ScriptError => e
      if ENV['PRY']
        require 'pry'; binding.pry
      else
        raise e
      end
    end
  end
end
