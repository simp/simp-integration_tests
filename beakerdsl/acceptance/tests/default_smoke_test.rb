test_name 'puppet install smoketest' do
  step 'puppet install smoketest: verify \'puppet help\' can be successfully called on
  all hosts' do
    hosts.each do |host|
      on host, puppet('help')
    end
  end
end