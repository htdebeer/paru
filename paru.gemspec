Gem::Specification.new do |s|
  s.name = 'paru'
  s.version = '0.2.5c'
  s.date = '2017-05-19'
  s.summary = 'Paru is a ruby wrapper around pandoc'
  s.description = 'Use Pandoc (http://www.pandoc.org) with ruby'
  s.authors = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.bindir = 'bin'
  s.executables = ['pandoc2yaml.rb', 'do-pandoc.rb']
  s.files = ['lib/paru.rb',
             'lib/paru/error.rb', 
             'lib/paru/pandoc_options.yaml',
             'lib/paru/pandoc.rb',
             'lib/paru/filter.rb',
             'lib/paru/selector.rb']
  s.files += Dir['lib/paru/filter/*.rb']
  s.homepage = 'https://heerdebeer.org/Software/markdown/paru/'
  s.license = 'GPL-3.0'
end
