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
      item[:optionItemName] = name
      item[:optionItemLabel] = label
    end
    items << item
  end
  result[:checkboxes] = items
  result
end

# copy origin folder, and save files into input folder
files = Dir.glob('/*')
# mkdir_p will not raise error if folder exists
FileUtils.mkdir_p('input')
FileUtils.cp_r(files, 'input')

# Able to process multi XMl files from input folder to output folder
json = []
inputs = Dir['input/*']

inputs.each_with_index do |file, i|
  content = File.open file 
  xml = Nokogiri::Slop content
  hash = parse_xml(xml)

  json << hash
end

# generate the final json file
sorted_json = json.sort { |a, b| a[:order] <=> b[:order] }
prettier_json = JSON.pretty_generate sorted_json
File.write("the-final.json", prettier_json)
