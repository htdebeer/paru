require_relative '../lib/paru/pandoc.rb'

p = Paru::Pandoc.new do |d|
  d.to :markdown
  d.from :html
  d.output 'test.html'
end

puts p.to_command


p = Paru::Pandoc.new do 
  to :latex
  from :html 
  css 'this_file.css'
  css 'that_file.css'
end
p.configure do 
  strict
  tab_stop 5
  indented_code_classes "algol"
  columns
end

puts p.to_command
