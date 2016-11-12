require 'rake/testtask'

Rake::TestTask.new do |t|
    t.libs << 'test'
end

task :default => :test

task :documentation do
  sh "cd documentation; ../examples/do-pandoc.rb documentation.md"
end

task :build do
  sh "gem build paru.gemspec; mv *.*.*.gem releases"
end
