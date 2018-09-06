require 'spec_helper_acceptance'

test_name 'integration_tests class'

describe 'integration_tests class' do
  let(:manifest) {
    <<-EOS
      file{ '/root/.beaker-suites.smoke_test.file':
        content => 'Beaker wrote this file!'
      }
    EOS
  }

  context 'default parameters' do
    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should create the smoke test file' do
      puppetserver = find_only_one('puppetserver')
      on puppetserver, 'test -f /root/.beaker-suites.smoke_test.file'
    end
  end
end
