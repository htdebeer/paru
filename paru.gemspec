require_relative "lib/paru.rb"

Gem::Specification.new do |s|
  s.name = 'paru'
  s.license = 'GPL-3.0'
  s.version = Paru::VERSION.join "."
  s.date = '2021-11-20'
  s.authors = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'

  s.summary = 'Paru is a ruby wrapper around pandoc'
  s.description = 'Control pandoc with Ruby and write pandoc filters in Ruby'
  s.homepage = 'https://heerdebeer.org/Software/markdown/paru/'
  s.required_ruby_version = ">= 2.6.8"

  s.bindir = 'bin'
  s.executables = ['pandoc2yaml.rb', 'do-pandoc.rb']
  s.files = [
      'lib/paru.rb',
      'lib/paru/pandoc_options.yaml'
  ]
  s.files += Dir['lib/paru/*.rb']
  s.files += Dir['lib/paru/filter/*.rb']
end
