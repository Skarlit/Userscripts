require 'nokogiri'
require 'json'
require 'open-uri'

class Downloader

  def cache(href=nil)
    if !Dir.exists?('cache')
      Dir.mkdir('cache')
    end
    if href
      filename = "#{href.split('/')[2]}.cache"
    else
      filename = "home.cache"
    end
    file_content = open("http://www.theclymb.com#{href}").read
    File.open("cache/#{filename}", 'w') {|f| f.write(file_content)}
    return Nokogiri::HTML(file_content)
  end

  def load_cache(id=nil)
    return nil if !Dir.exists?('cache')
    if id
      file_path = "cache/#{id}.cache"
    else
      file_path = "cache/home.cache"
    end
    return Nokogiri::HTML(File.open(file_path))
  end

  def cleanup
    if Dir.exists?('cache')
      exec("rm -rf cache")
    end
  end
end

class Parser
  attr_accessor :downloader, :homepage, :doc
  def initialize(cache=false, id=nil)
    @downloader = Downloader.new
    if cache
      @homepage = @downloader.load_cache(id)
    else
      @homepage = @downloader.cache
    end
  end

  def extractAdventureLinks
    @adventure_links ||= []
    puts @homepage
    @homepage.css("a").each do |link|
      @adventure_links.push(link["href"]) if link["href"] && link["href"].match(/^\/adventures\/\d+/)
    end
    if !@adventure_links.empty?
      puts 'Links Found: '
      puts @adventure_links
      puts 'Saving to adventure_links.json'
      Dir.mkdir('data') if !Dir.exists?('data') 
      File.open('data/adventure_links.json', 'w') do |f|
        f.write({'adventure_links'=> @adventure_links}.to_json)
      end
    end
  end

  def cacheAll
    @adventure_links.each do |href|
      puts "fetching #{href}..."
      @downloader.cache(href)
      sleep(1)
    end
  end

  def parseAdventurePage(filepath)
    doc_data = {}
    @doc = Nokogiri::HTML(File.read(filepath))
    doc_data['trav-top'] = {
      'title' => @doc.css('.trav-section-title.primary')[0].text
    } 
  end
end


def Runner
  p = Parser.new(true)
  p.extractAdventureLinks
  p.cacheAll
end


Runner()