require 'nokogiri'
require 'json'
require 'fileutils'

# define a HTML/XML parse method
def parse_xml(file)
  # first layer of json data
  title = file.css('template div p').text 
  order = title.split('.')[0].to_i

  result = {
    order: order,
    title: title,
    subtitle: file.css('template div div').first.text
  }

  # second layer of json data, an array of hashes
  items = []
  file.css('template div div div').map.with_index do |t, i|
    item = {
      id: i,
      optionItemTitle: t['title']
    }

    t.search('label').map do |l|
      name = l['for']
      label = l.text
      item[:optionName] = name
      item[:optionLabel] = label
    end
    items << item
  end
  result[:checkboxes] = items
  result
end

# copy origin folder, and save files into input folder
files = Dir.glob('your-orgin-folder/*')
FileUtils.mkdir('input') unless File.exists?('input')
FileUtils.cp_r(files, 'input')

# replace vue files' extension to xml
Dir['input/*.vue'].each do |f|
  FileUtils.mv f, "input/#{File.basename(f,'.*')}.xml"
end

# Able to process multi XMl files from input folder to output folder
json = []
inputs = Dir['input/*.xml']

inputs.each_with_index do |file, i|
  # json[:id] = i
  content = File.open file 
  xml = Nokogiri::Slop content
  hash = parse_xml(xml)

  json << hash
end

# generate the final json file
prettier_json = JSON.pretty_generate json
File.write("the-final.json", prettier_json)
