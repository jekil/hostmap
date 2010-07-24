require 'rake/testtask'
require 'rake/rdoctask'


Rake::TestTask.new('test') do |t|
  t.pattern = 'lib/**/*test.rb'
  t.warning = true
end

Rake::RDocTask.new('rdoc') do |t|
  t.rdoc_dir = 'doc/api'
  t.rdoc_files.include('lib/**/*.rb')
  t.title = "Hostmap API documentation"
end

desc "Generate pdf readme"
task 'lyxdoc' do
  `cd doc && lyx -e pdf README.lyx`
end

task :default => []