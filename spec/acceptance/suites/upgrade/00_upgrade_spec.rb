require 'spec_helper_acceptance'

# The `upgrade` suite validates the SIMP user guide's [General Upgrade
# Instructions for incremental upgrades][u0].
#
# It automates the [Verify SIMP server RPM upgrade pre-release checklist][u1].
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
# [u1]: https://github.com/simp/simp-doc/blob/aebb9f7/docs/contributors_guide/maintenance/iso_release_procedures/Pre_Release_Checklist.rst#verify-simp-server-rpm-upgrade
#
#
# - https://simp.readthedocs.io/en/latest/contributors_guide/maintenance/iso_release_procedures/Pre_Release_Checklist.html#verify-simp-server-rpm-upgrade
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
    default_file_glob = "*#{host_os_version}*.iso"
    if (iso_files = ENV['BEAKER_upgrade__new_simp_iso_path'])
      isos = iso_files.to_s.split(%r{[:,]})
    else
      isos = Dir[default_file_glob]
    end
    return isos unless isos.empty?
    fail <<-NO_ISO_FILE_ERROR.gsub(/^ {6}/,'')

      --------------------------------------------------------------------------------
      ERROR: No SIMP ISO(s) to upload for upgrade!
      --------------------------------------------------------------------------------

      This test requires at least one newer SIMP .iso

      You can provide .iso files either by setting the environment variable:

          BEAKER_upgrade__new_simp_iso_path=/path/to/iso-file.iso

      Or:

      Place a file that matches the glob '#{default_file_glob}'
      into the top directory of this project.

      --------------------------------------------------------------------------------

    NO_ISO_FILE_ERROR
  end

  let(:puppetserver) { find_at_most_one_host_with_role hosts, 'master' }
  let(:puppet_agent_t) { 'puppet agent -t --detailed-exitcodes' }
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
      # try to prevent puppet agent from running
      on puppetserver, 'puppet resource service puppet'
      on puppetserver, 'puppet resource cron puppetagent ensure=absent'
      on puppetserver, 'puppet resource service puppet'
      on puppetserver, 'puppet resource service puppetserver'
      on puppetserver, 'puppet resource service named'
      @original_simp_version = on(puppetserver, 'cat /etc/simp/simp.version').stdout.strip
      @puppetserver_fqdn = puppetserver.node_name
      ### on puppetserver, 'puppet resource service puppetserver ensure=running'
      ### on puppetserver, 'puppet resource service named ensure=running'
    end

    it 'uploads the ISO file(s)' do
      expect(iso_files).not_to be_empty

      on puppetserver, 'mkdir -p /var/isos'
      iso_files.each do |iso_file|
        puppetserver.do_rsync_to iso_file, "/var/isos/#{File.basename(iso_file)}"
      end
    end

    it 'runs the unpack_dvd script' do
      iso_files.each do |iso_file|
        on puppetserver, "unpack_dvd /var/isos/#{File.basename(iso_file)}"
      end
      on puppetserver, 'yum clean all; yum makecache'

      # Specific 6.1.0->* upgrade instructions, due to SIMP-5383
      if @original_simp_version.start_with? '6.1.'
        puts "== SPECIAL 6.1 -> 6.2 upgrade instructions, due to SIMP-5383"
        on puppetserver, 'echo exclude=puppet-agent >> /etc/yum.conf'
        ##on puppetserver, 'yum -y install yum-versionlock'
        ##on puppetserver, 'yum versionlock add puppet-agent'
      end

      pq_config =<<-PQCONFIG
{
    "puppetdb" : {
      "server_urls" : "http://127.0.0.1:8138",
      "cacert" : "/etc/puppetlabs/puppet/ssl/certs/ca.pem",
      "cert" : "/etc/puppetlabs/puppet/ssl/certs/#{@puppetserver_fqdn}.pem",
      "key" : "/etc/puppetlabs/puppet/ssl/private_keys/#{@puppetserver_fqdn}.pem"
    }
}
PQCONFIG

      on puppetserver, 'mkdir -p .puppetlabs/client-tools/'
      create_remote_file(puppetserver, "/root/.puppetlabs/client-tools/puppetdb.conf", pq_config)
      on puppetserver, 'yum --verbose --rpmverbosity=warn -y update'
      n=0
      n += 1 ; on puppetserver, "#{puppet_agent_t} |& tee /root/puppet-agent.log.#{n}", :acceptable_exit_codes => [0,2,6]
      pq_cmd = %Q[puppet query  "resources [certname,title]{ type = 'Class' and nodes { certname = '$(hostname -f)' and  deactivated is null and expired is null} order by certname }" | ruby -r json -r yaml -e "j=JSON.parse(STDIN.read); h = {}; j.each{|x| h[x['certname']]||= []; h[x['certname']] << x['title'] };  puts h.to_yaml" > puppetserver-classes.#{n}.yaml]
      on puppetserver, pq_cmd
      on puppetserver, 'puppet resource cron puppetagent ensure=absent'
      on puppetserver, 'systemctl restart puppetserver'
      20.times do
        n += 1 ; on puppetserver, "#{puppet_agent_t} --noop |& tee /root/puppet-agent.log.#{n}", :acceptable_exit_codes => [0,2,6]
        on puppetserver, 'puppet resource cron puppetagent ensure=absent'
        pq_cmd = %Q[puppet query  "resources [certname,title]{ type = 'Class' and nodes { certname = '$(hostname -f)' and  deactivated is null and expired is null} order by certname }" | ruby -r json -r yaml -e "j=JSON.parse(STDIN.read); h = {}; j.each{|x| h[x['certname']]||= []; h[x['certname']] << x['title'] };  puts h.to_yaml" > puppetserver-classes.#{n}.yaml]
        on puppetserver, pq_cmd
      end
      on puppetserver, 'ps -ef | grep puppetserver'
      on puppetserver, 'cat /etc/sysconfig/puppetserver'
require 'pry'; binding.pry

      # SIMP-5021 is not as solved as we thought, because the RPM install  but a workaround will be documented
      #
      # exit code 2 = puppet changes + something (because it's an upgrade)
      # exit code 6 = puppet changes + puppetserver failed SIMP-5021, BUT systemd should immediately restarts itself
      if r1.exit_code == 6
        expect(r1.stderr).to match(/Puppet::Error: Cannot determine basic system flavour/)
      end

      r2 = on puppetserver, 'puppet agent -t', :acceptable_exit_codes => [2]
      r3 = on puppetserver, 'puppet resource service puppetserver'
      expect(r3.stdout).to match(/ensure => 'running'/)
    end
  end
end
