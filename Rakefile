require "rake/testtask"
require "yard"

Rake::TestTask.new do |t|
    t.libs << 'test'
end

task :default => :test

YARD::Rake::YardocTask.new do |t|
    t.files = ['LICENCE', 'lib/paru.rb', 'lib/**/*.rb']
end

task :generate_index_md do
    sh "cd documentation; ../bin/do-pandoc.rb documentation.md"
end

task :build do
    Rake::Task["test"].execute
    Rake::Task["yard"].execute
    sh "gem build paru.gemspec; mv *.*.*.gem releases"
    Rake::Task["generate_index_md"].execute
end
