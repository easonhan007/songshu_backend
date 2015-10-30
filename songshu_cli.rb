require 'optparse'
require 'pp'
require 'ostruct'
require 'rest-client'
require 'nokogiri'

class SongshuCLI
  attr_reader :options, :is_production, :net_time

  def initialize
    @options = self.class.parse()
    @is_production = @options.production || false
    @url_builder = UrlBilder.new(@is_production)
  end

  def self.parse
    op = OpenStruct.new
    OptionParser.new do |opts|
      opts.banner = "Usage: songshu_cli.rb [options]"

      opts.on('-l', '--list', 'list new articles', 'EXAMPLE: songshu_cli -l') do |v|
        op.list = true
      end

      opts.on('-p', '--production', 'fetch the production env data', 'EXAMPLE: songshu_cli -l -p') do |v|
        op.production = true
      end

      opts.on('-d', '--display-net-time', 'display net time') do |v|
        op.net_time = true
      end

      opts.on('-i', '--id=ID', 'get article with id', 'EXAMPLE: songshu_cli -i 1234') do |v|
        op.id = v
      end

      opts.on_tail('-h', '--help', 'show this message') do
        puts opts
        exit
      end

      opts.on_tail('--version', 'show version') do
        puts '0.1'
        exit
      end
    end.parse!
    op
  end #parse

  def handle_options
    if @options.list
      display_list
    elsif @options.id
      display_article(@options.id)
    else
      puts 'nothing to do'
      exit()
    end #if
    display_net_time if @options.net_time
  end

  def display_list
    res = get(@url_builder.list_url) 
    res.each do |post|
      puts "[#{post['post_id']}] - #{post['title']}"
    end
  end

  def display_article(id)
    res = get(@url_builder.article_url(id)) 
    dom = Nokogiri.parse "<html><body>#{res['content']}/</body></html>"
    dom.css('p').each {|p| puts p.text}
  end

  def display_net_time
    puts "#{@net_time}s" if @net_time
  end

  def get(url)
    begin 
      t_start = Time.now
      res = RestClient.get(url) 
      t_end = Time.now
      @net_time = t_end - t_start
      JSON.parse res 
    rescue RestClient::ResourceNotFound
      puts "404 not found #{url}"
      exit
    rescue Errno::ECONNREFUSED
      puts "Server is down OR not connect to internet"
      exit(1)
    end
  end

  class UrlBilder
    attr_reader :domain

    def initialize(is_production = false)
      @is_production = is_production
      @domain = is_production ? 'https://tranquil-tor-1576.herokuapp.com/api/': 'http://localhost:4567/api/'
    end

    def list_url
      @domain + 'posts'
    end

    def article_url(id)
      @domain + 'posts/' + id
    end
    
  end

end

SongshuCLI.new.handle_options
