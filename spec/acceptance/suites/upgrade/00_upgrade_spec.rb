require 'spec_helper_acceptance'

# The `upgrade` suite validates the SIMP user guide's [General Upgrade
# Instructions for incremental upgrades][u0].
#
# Example:
#
#   BEAKER_vagrant_box_tree=$vagrant_boxes_dir \
#   BEAKER_box__puppet="simpci/SIMP-6.1.0-0-Powered-by-CentOS-7.0-x86_64" \
#   BEAKER_upgrade__new_simp_iso_path=$PWD\SIMP-6.2.0-RC1.el6-CentOS-6.9-x86_64.iso \
#   bundle exec rake beaker:suites[upgrade]
#
# Requirements:
#
# - The SUT (`BEAKER_box__puppet`) is a PREVIOUS version of SIMP.
# - The ISO (`BEAKER_upgrade__new_simp_iso_path`) is the current version of SIMP.
#
# [u0]: https://github.com/simp/simp-doc/blob/8277eab/docs/user_guide/Upgrade_SIMP/General_Upgrade_Instructions.rst#incremental-updates

# - https://simp.readthedocs.io/en/master/user_guide/Upgrade_SIMP.html
# - https://simp.readthedocs.io/en/master/user_guide/Upgrade_SIMP/General_Upgrade_Instructions.html
# - https://simp.readthedocs.io/en/master/user_guide/Upgrade_SIMP/Version_Specific_Upgrade_Instructions.html
# - https://simp.readthedocs.io/en/master/user_guide/HOWTO/Upgrade_SIMP.html
#

test_name 'General Upgrade: incremental upgrades'

describe 'when an older version of SIMP' do
  let(:iso_files) do
    puppetserver      = find_at_most_one_host_with_role hosts, 'master'
    host_os_version   = on(puppetserver, 'echo  "$(facter os.name)-$(facter os.release.major)"').stdout.strip
    if (iso_files = ENV['BEAKER_upgrade__new_simp_iso_path'])
      iso_files.to_s.split(%r{[:,]})
    else
      Dir["*#{host_os_version}*.iso"]
    end
  end

  let(:puppetserver) { find_at_most_one_host_with_role hosts, 'master' }
  let(:host_simp_version) do
    puppetserver = find_at_most_one_host_with_role hosts, 'master'
    on(puppetserver, 'cat /etc/simp/simp.version').stdout.strip
  end

  #  Upgrade process derived from:
  #
  #   https://github.com/simp/simp-doc/blob/8277eab/docs/user_guide/Upgrade_SIMP/General_Upgrade_Instructions.rst#incremental-updates
  #
  context 'when upgrading incrementally' do
    before :all do
      # FIXME: this is a workaround for troubleshooting failed puppetservers.
      # It should not be necesary under normal circumstances.
      puppetserver = find_at_most_one_host_with_role hosts, 'master'
      on puppetserver, 'puppet resource service puppetserver'
      on puppetserver, 'puppet resource service named'
      on puppetserver, 'puppet resource service puppetserver ensure=running'
      on puppetserver, 'puppet resource service named ensure=running'
    end

    it 'uploads the ISO file(s)' do
      on puppetserver, 'mkdir -p /var/isos'
      iso_files.each do |iso_file|
        puppetserver.do_rsync_to iso_file, '/var/isos/'
      end
    end

    #  Upgrade process derived from:
    #
    #    https://github.com/simp/simp-doc/blob/8277eab0a38f3c995a762e017fe0cc65c7ac3bb8/docs/getting_started_guide/ISO_Install/SIMP_Server_Installation.rst
    #
    it 'runs the unpack_dvd script' do
      iso_files.each do |iso_file|
        on puppetserver, "unpack_dvd /var/isos/#{iso_file}"
      end
      on puppetserver, 'yum clean all; yum makecache'
      on puppetserver, 'puppet agent -t', :acceptable_exit_codes => [2]
    end
  end
end
