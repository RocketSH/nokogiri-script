require 'nokogiri'

file = File.read("./TrainingPreference.xml")
doc = Nokogiri::Slop file

def parse_xml(doc)
  doc.search("div").map do |t|
    result = {
      title: t['title'] 
    }

    t.xpath("//label").map do |l|
      name = l['for']
      label = l.text
      result[:name] = name
      result[:lable] = label
    end

    result
  end
end

puts parse_xml(doc)
