require 'fileutils'
namespace :beakerdsl do
  def save_failed_test_assets(label, nodeset, datetime, log_file)
    fail_dir =    File.join('failures', "#{label}.#{datetime}")
    vagrant_file = File.join('.vagrant', 'beaker_vagrant_files', "#{nodeset}_vagrant_hosts.yaml", 'Vagrantfile')
    FileUtils.mkdir_p fail_dir
    FileUtils.cp vagrant_file, fail_dir
    FileUtils.mv log_file, fail_dir
  end


  def run_with_log_and_save_failures(label, nodeset)
    datetime = `date '+%Y%m%d%H%M%S'`.strip
    log_file = "_log.beaker.#{label}.#{datetime}"
    cmd = "bundle exec beaker \\\n \
      --hosts acceptance/config/#{nodeset}_vagrant_hosts.yaml \\\n \
      --options-file acceptance/setup/additional_options.rb \\\n \
      --pre-suite acceptance/setup/default_pre_suite.rb \\\n \
      --tests acceptance/tests/default_smoke_test.rb \\\n \
      --xml-time-order \\\n \
      --preserve-hosts onfail \\\n \
      --log-level trace \\\n \
      |& tee #{log_file} \
      "
      ##--no-configure \\\n \
      # --parse-only \\\n \
    # --dry-run \
    begin
      sh cmd
      raise 'BEAKER FAILED' unless $?.success?
    rescue RuntimeError => e
      puts "========= RESCUE BLOCK"
      require 'pry'; binding.pry
      save_failed_test_assets(label, nodeset, datetime, log_file)
      require 'pry'; binding.pry
    ensure e
      puts "========= ENSURE BLOCK"
    end
  end

  namespace :run do
    desc 'straight beaker DSL test'
    task :simp do
      run_with_log_and_save_failures('simp', 'default')
    end
    desc 'straight beaker DSL test using vanilla centos'
    task :vanilla do
      run_with_log_and_save_failures('vanilla', 'vanilla')
    end
  end
end
