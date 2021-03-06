require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'dalli'
require 'uri'

class Contender
  attr_accessor :url
  attr_accessor :content_length
  
  def initialize u
    self.url = u
    response = nil
    self.seen_again!
  end
  
  def seen_again! 
    CACHE.set("seen:#{self.url}", self.seen.to_i + 1)
  end
  
  def seen
    CACHE.get("seen:#{self.url}") rescue 0
  end
  
  def weight
    seen
  end
  
  def size
    return @size if @size
    response = nil
    uri = URI.parse(self.url)
    Net::HTTP.start(uri.host, 80) {|http|
      path = "#{uri.path}?#{uri.query}"
      puts path
      response = http.head(path)
    }
    @size = response['content-length'].to_i
  end

end


class ImageScraper

  def self.get_the_biggest_image url
    doc = Nokogiri::HTML(open(url).read)
    uri = URI.parse(url)
    
    contenders = []
    doc.css("img").each do|img| 
      image_url = img.attributes["src"]
      image_uri = URI.parse(image_url)
      
      if(!image_uri.absolute?)
        image_uri = URI.parse("http://#{uri.host}")
        image_uri.merge!(URI.parse(image_url))
      end
      
      contenders << Contender.new(image_uri.to_s)
    end
    
    contenders.reject! {|a| a.seen > contenders[0].seen*5}
    contenders.sort! {|a,b| a.weight <=> b.weight }
    contenders.reverse[0..5].sort! {|a,b| puts a.size; a.size <=> b.size}
    contenders.reverse.pop.url.to_s
  end

end