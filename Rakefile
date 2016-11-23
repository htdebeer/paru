require "rake/testtask"
require "rdoc/task"

Rake::TestTask.new do |t|
    t.libs << 'test'
end

task :default => :test

Rake::RDocTask.new do |t|
  t.main = "README.rdoc"
  t.rdoc_files.include("documentation/README.rdoc", "lib/**/*.rb")
  t.rdoc_dir = "documentation/api-doc"
  t.title = "Paru API documentation"
end

task :documentation do
  sh "cd documentation; ../examples/do-pandoc.rb documentation.md"
end

task :build do
  sh "gem build paru.gemspec; mv *.*.*.gem releases"
end
