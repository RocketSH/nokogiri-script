require 'nokogiri'
require 'json'

# define a HTML/XML parse method
def parse_xml(file)
  # get data from a parent tag
  file.search('div').map do |t|
    result = {
      title: t['title']
    }
    # get data from child tags
    t.search('label').map do |l|
      name = l['for']
      label = l.text
      result[:name] = name
      result[:label] = label
    end

    result
  end
end

# Able to process multi XMl files from input folder to output folder
input = Dir['input/*.xml']
input.each do |el|
  file_name = File.basename(el, '.xml')
  file = File.read el
  xml = Nokogiri::Slop file
  hash = parse_xml(xml)
  json = JSON.pretty_generate hash

  File.write("output/#{file_name}.json", json)
end
