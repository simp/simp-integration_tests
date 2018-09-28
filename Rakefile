begin
  require 'simp/rake/beaker'
  Simp::Rake::Beaker.new(File.dirname(__FILE__))
rescue LoadError => e
  warn "WARNING: could not load tasks from 'simp/rake/beaker'; " + \
    'did you bundle `--with system_tests`?'
end

