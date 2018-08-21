puts '====================================================== acceptance/setup/default_pre_suite.rb'
## This is unecessary, and will FAIL on a simp server:

###unless ENV['BEAKER_provision'] == 'no'
###  hosts.each do |host|
###    # Install Puppet
###    if host.is_pe?
###      install_pe
###    else
###      install_puppet
###    end
###  end
###end
