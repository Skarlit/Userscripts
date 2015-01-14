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
    # @downloader = Downloader.new
    # if cache
    #   @homepage = @downloader.load_cache(id)
    # else
    #   @homepage = @downloader.cache
    # end
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

  def parseAll
    if !Dir.exists?('json')
      Dir.mkdir('json')
    end
    Dir['cache/*.cache'].each do |file| 
      f = File.open(file)
      if File.extname(f) == '.cache'
        parseAdventurePage(f)
      end
    end
  end

  def parseAdventurePage(file)
    doc_data = {}
    id = File.basename(file, '.cache')
    @doc = Nokogiri::HTML(File.read("cache/#{id}.cache"))
    trip = {
      'title' => @doc.css('.trav-section-title.primary')[0].text,
      'subtitle' => @doc.css('.trav-section-title.sub')[0].text,
      'price_person' => @doc.css('.trav-price')[0].text,
      'price_person_msrp' => @doc.css('.trav-msrp')[0].text,
      'duration' => @doc.css('.trav-base-font')[0].text,
      'discount' => @doc.css('.trav-base-font')[1].text,
      'short_description' => @doc.css('.trav-short-description').text,
      'phone' => @doc.css('.icon-phone + .mobile-hide').text,
      'email' => @doc.css('.icon-mail + .mobile-hide').text,
      'images' => @doc.css('.trav-hero-img').map {|img| img.attributes['style'].value.split(';')[0].scan(/(?<=\').*(?=\')/)[0]},
      'start_place' => @doc.css('.tg-unsocial > .layout-top-box > .location-label')[0].text,
      'end_place' => @doc.css('.tg-unsocial > .layout-top-box > .location-label')[1].text,
      'minimum_age' => @doc.css('.tg-unsocial > .layout-trans-top > .layout-controls:contains("MINIMUM AGE") .trav-husky-font').text,
      'act_difficulty' =>  @doc.css('.tg-unsocial .trav-fitness-dot').length,
      'passport' => @doc.css('.tg-unsocial').children.last.children[0].css('.trav-husky-font').text,
      'accommodations' => @doc.css('.tg-unsocial').children.last.children[1].css('.trav-husky-font').text,
      'trip_activities' => @doc.css('.media-vertical-list img').map { |img| img['alt']}
    }
    File.open("json/#{id}.json", 'w') do |file|
      file.write(trip.to_json)
    end
  end
end


def Runner
  p = Parser.new(true)
  # p.extractAdventureLinks
  # p.cacheAll
  p.parseAll
end


Runner()
