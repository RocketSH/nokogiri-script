require 'nokogiri'
require 'json'

input = Dir['input/*.xml']
input.each do |el|
  filename = File.basename el
  file = File.read el
  xml = Nokogiri::Slop file
  hash = parse_xml xml
  json = JSON.pretty_generate hash
  File.write(filename.json, json)
end

def parse_xml(file)
  file.search('div').map do |t|
    result = {
      title: t['title']
    }
    t.search('label').map do |l|
      name = l['for']
      label = l.text
      result[:name] = name
      result[:label] = label
    end

    result
  end
end
