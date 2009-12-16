require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'src/PlugMan'

PROJECT_NAME = "PlugMan"
PROJECT_VERSION = PlugMan::PLUGMAN_VERSION

desc "Default Task"
task :default => [ :usage ]

desc "Show rake usage."
task :usage do
  puts "Usage:    rake target"
  puts "Some targets include:"
  puts "    test - run unit test."
  puts "    doc - create rdocs."
  puts "    package/repackage - create/recreate tar.gz archive distribution."
  puts "    text_demo - runs the 'Texter' demo."
  puts "    gtk_demo - runs the Gtk demo, requires libgtk2-ruby to be installed."
end

task :text_demo do
  old_dir = Dir.getwd
  Dir.chdir("./src")
  load "demos/Texter.rb"
  Dir.chdir(old_dir)
end

task :gtk_demo do
  old_dir = Dir.getwd
  Dir.chdir("./src")
  load "demos/GtkDemo.rb"
  Dir.chdir(old_dir)
end

# Run the unit tests
desc "Run unit tests"
Rake::TestTask.new("test") { |t|
  #t.libs << "test"
  t.pattern = 'test/test*.rb'
  t.verbose = true
}

# Genereate the RDoc documentation
desc "Create rdoc documentation"
Rake::RDocTask.new("doc") { |rdoc|
  rdoc.title = "#{PROJECT_NAME} #{PROJECT_VERSION}"
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('src/**/*.rb')
}

desc "Create the source package"
Rake::PackageTask.new(PROJECT_NAME, PROJECT_VERSION) do |p|
  p.need_tar_gz = true
  p.package_files.include("src/**/*")
  p.package_files.include("doc/**/*")
  p.package_files.include("test/**/*")
  p.package_files.include("./*")
  p.package_files.exclude("./pkg")
end
