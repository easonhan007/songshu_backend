# encoding: utf-8
require 'rest-client'
require 'nokogiri'
require 'ostruct'
require 'pp'

class PostBasicInfoPaser
  attr_accessor :url
  attr_reader :page

  def initialize(tag='原创')
    validate_tag(tag)
    @url = URI.escape('http://songshuhui.net/archives/tag/' + tag)
    @page = Nokogiri::HTML(RestClient.get(@url))
  end

  def validate_tag(tag)
    unless ['原创', '译文'].include?(tag)
      raise 'tag should be either 原创 or 译文'
    end
  end

  def current_post_id
    @page.at_css('.storytitle > a')[:href].split('/').last.to_i
  end

  def total_page()
    @page.css('.last')[0][:href].split('/').last.to_i
  end

  def content_by_page(page=1)
    origin = @url
    @url = url_by_page(page)
    puts @url
    @page = Nokogiri::HTML(RestClient.get(@url))
    @url = origin
    content()
  end

  def url_by_page(page=1)
    @url + "/page/#{page}"
  end

  # title url post_id author published_at category brief comment_count image content
  def content()
    content = []
    article_p = ArticleParser.new
    puts 'getting basic information of ' + @url

    dom_post_div = @page.css('#content .step').select {|div| div[:id] != 'listheader'}
    dom_post_div.pop
    dom_post_div.each do |div|
      item = OpenStruct.new

      dom_title = div.css('.storytitle > a').first
      item.title = dom_title.text
      item.url = dom_title[:href]
      item.post_id = item.url.split('/').last.to_i

      dom_author = div.css('.metax').first
      item.author = dom_author.css('a').text
      item.published_at = Time.parse(dom_author.text.split(' ')[-2..-1].join(' ')).to_datetime
      item.category = dom_author.css('em').text.split(':').last.strip

      dom_brief = div.css('.storycontent').first      
      item.brief = dom_brief.text

      dom_comment = div.css('.feedback').first
      item.comment_count = dom_comment.text.split(' ').first.to_i

      dom_image = div.css('img').first
      item.image = dom_image[:src]

      item.content = article_p.content_by_id(item.post_id)

      content.push(item)
    end #each
    return content
  end
end

class TranslatedPostInfoPaser < PostBasicInfoPaser
  def initialize()
    @url = URI.escape('http://songshuhui.net/archives/tag/译文')
    @page = Nokogiri::HTML(RestClient.get(@url))
  end
end

class ArticleParser
  attr_reader :url, :page, :id

  def content
    # 这里要加个注释
    # 这个页面很变态，隐藏了1个textarea，这个里面就是全文内容
    div = @page.css('textarea p')
    div.to_html
  end

  def content_by_id(id)
    @id = id.to_s
    @url = 'http://songshuhui.net/archives/' + @id
    @page = Nokogiri::HTML(RestClient.get(@url))
    puts 'getting content of ' + @url
    content
  end

end

class ArticlePersistent
  def initialize
    @p = PostBasicInfoPaser.new()
  end

  def anything_new?
    if Post.lasted_post_id
      puts "DB id #{Post.lasted_post_id}, SITE id #{@p.current_post_id}"
      @p.current_post_id > Post.lasted_post_id
    else
      true
    end
  end

  def fetch_all_posts
    all_pages = @p.total_page()
    all_pages.times do |page|
      page = page + 1
      content = @p.content_by_page(page)
      content.each do |c|
        if c.post_id
          res = Post.first_or_create({post_id: c.post_id}, c.to_h)
          puts "save #{c.title} #{res.saved?}"
        end #if
      end #each
    end #times
  end

  def fetch_one_page_posts
    content = @p.content_by_page()
    content.each do |c|
      if c.post_id
        res = Post.first_or_create({post_id: c.post_id}, c.to_h)
        puts "save #{c.title} #{res.saved?}"
      end #if
    end#each
  end

  def partial_update(page=1)
    if anything_new?
      fetch_one_page_posts
    end #if
  end

end

class TranslatedArticlePersistent
  def initialize
    @p = TranslatedPostInfoPaser.new()
  end

  def anything_new?
    if Post.lasted_post_id
      puts "DB id #{Post.lasted_post_id}, SITE id #{@p.current_post_id}"
      @p.current_post_id > Post.lasted_translated_post_id
    else
      true
    end
  end

  def fetch_all_posts
    all_pages = @p.total_page()
    all_pages.times do |page|
      page = page + 1
      content = @p.content_by_page(page)
      content.each do |c|
        if c.post_id
          c.type = 'translated'
          res = Post.first_or_create({post_id: c.post_id}, c.to_h)
          puts "save TRANSLATED #{c.title} #{res.saved?}"
        end #if
      end #each
    end #times
  end

  def fetch_one_page_posts
    content = @p.content_by_page()
    content.each do |c|
      if c.post_id
        c.type = 'translated'
        res = Post.first_or_create({post_id: c.post_id}, c.to_h)
        puts "save TRANSLATED #{c.title} #{res.saved?}"
      end #if
    end#each
  end

  def partial_update(page=1)
    if anything_new?
      fetch_one_page_posts
    end #if
  end

end


