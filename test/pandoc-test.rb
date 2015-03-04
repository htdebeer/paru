require_relative '../lib/paru/pandoc.rb'

p = Paru::Pandoc.new do
  from :markdown
  to :html5
  standalone
  toc false
  css 'sfsdf'
  css 'dfdgf'
  variable "D"
  variable "E:90"
  output File.join(__dir__, 'test.html')
end 
#<< IO.read(File.join(__dir__, 'test.markdown'))

puts p.to_command

p = Paru::Pandoc.new.configure { toc }.configure {css "dfdf"}.css "SDfsdf"

puts p.to_command
