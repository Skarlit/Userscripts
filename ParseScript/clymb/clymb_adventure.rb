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
    return Nokogiri::HTML(File.read(file_path))
  end

  def cleanup
    if Dir.exists?('cache')
      exec("rm -rf cache")
    end
  end
end

class Parser
  attr_accessor :downloader, :homePage
  def initialize(cache=false)
    @downloader = Downloader.new
    if cache
      @homePage = @downloader.load_cache
    else
      @homePage = @downloader.cache
    end
  end

  def extractAdventureLinks
    @adventure_links ||= []
    @homePage.css("a").each do |link|
      @adventure_links.push(link["href"]) if link["href"] && link["href"].match(/^\/adventures\/\d+/)
    end
    puts 'Links Found: '
    puts @adventure_links
    puts 'Saving to adventure_links.json'
    Dir.mkdir('data') if !Dir.exists?('data') 
    File.open('data/adventure_links.json', 'w') do |f|
      f.write(@adventure_links.to_json)
    end
  end
end


def Runner
  p = Parser.new
  p.extractAdventureLinks
end

Runner()