Gem::Specification.new do |s|
  s.name = 'paru'
  s.version = '0.4.0.1'
  s.date = '2020-02-18'
  s.summary = 'Paru is a ruby wrapper around pandoc'
  s.description = 'Use Pandoc (http://www.pandoc.org) with ruby'
  s.authors = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.required_ruby_version = ">= 2.4"
  s.bindir = 'bin'
  s.executables = ['pandoc2yaml.rb', 'do-pandoc.rb']
  s.files = [
      'lib/paru.rb',
      'lib/paru/pandoc_options_version_1.yaml',
      'lib/paru/pandoc_options_version_2.yaml'
  ]
  s.files += Dir['lib/paru/*.rb']
  s.files += Dir['lib/paru/filter/*.rb']
  s.homepage = 'https://heerdebeer.org/Software/markdown/paru/'
  s.license = 'GPL-3.0'
end
