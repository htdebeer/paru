require "bundler/gem_tasks"
require "rake/testtask"
require "yard"

Rake::TestTask.new do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList["test/**/test_*.rb"]
    t.warning = false
end

task :default => :test

YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/paru.rb', 'lib/**/*.rb']
    t.stats_options = ["--list-undoc"]
end

task :generate_doc do
    sh "cd documentation; ../bin/do-pandoc.rb documentation.md"
    sh "cd documentation; ../bin/do-pandoc.rb github_README.md"
end

task :build do
    Rake::Task["test"].execute
    Rake::Task["yard"].execute
    Rake::Task["generate_doc"].execute
end
