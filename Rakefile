require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['tests/test*.rb']
  t.verbose = true
end

desc "Run Tests"
task :default => :test
