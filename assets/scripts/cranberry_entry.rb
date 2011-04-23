#require 'open-uri'

class CranberryEntry
  @@entries = []
  def self.update
    # openuri doesn't work. Ir raises StackOverFlow.
    #doc = Nokogiri::XML(open("http://rss.cnn.com/rss/cnn_topstories.rss"))
    url = java.net.URL.new("http://rss.cnn.com/rss/cnn_topstories.rss")
    is = url.openConnection().getInputStream()
    doc = Nokogiri::XML::Document.parse(is)
    items = doc.xpath("//item")
    items.each do |item|
      title = item.xpath("title").text
      url = item.xpath("link").text
      description = item.xpath("description").text
      pubdate = item.xpath("pubDate").text
      @@entries << CranberryEntry.new(title, url, description, pubdate)
    end
  end

  def self.info
    "creating newsfeeds entries"
  end

  attr_reader :title, :url, :description, :pubdate
  def initialize(title, url, description, pubdate)
    @title = title
    @url = url
    @description = description
    @pubdate = pubdate
  end
end