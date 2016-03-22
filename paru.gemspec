Gem::Specification.new do |s|
  s.name = 'paru'
  s.version = '0.1.0'
  s.date = '2016-01-23'
  s.summary = 'Paru is a ruby wrapper around pandoc'
  s.description = 'Use Pandoc (http://www.pandoc.org) with ruby'
  s.authors = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.files = ['lib/paru.rb', 
             'lib/paru/pandoc_options.yaml',
             'lib/paru/pandoc.rb',
             'lib/paru/filter.rb']
  s.files += Dir['lib/paru/filter/*.rb']
  s.homepage = 'https://heerdebeer.org/Software/markdown/paru/'
  s.license = 'GPL3'
end
