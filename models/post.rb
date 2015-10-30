class Post
  include DataMapper::Resource

  property :id, Serial
  property :title, String, length: 255
  property :url, String, length: 255
  property :type, String, length: 255 #译文 or  原创
  property :content, Text
  property :author, String
  property :image, String, length: 255
  property :brief, Text
  property :category, String
  property :comment_count, Integer
  property :published_at, DateTime
  property :post_id, Integer

  def self.per_page
    15
  end

  def self.basic_info_return_fields
    %w[id title author post_id url image brief category comment_count published_at].map {|i| i.to_sym}
  end

  def self.article_return_fields
    %w[id title author category comment_count published_at post_id content].map {|i| i.to_sym}
  end

  def self.lasted_post_id
    Post.all(conditions: ['type is NULL'], limit: 1, order: [:post_id.desc]).first.post_id rescue 0
  end

  def self.lasted_translated_post_id
    Post.all(type: 'translated', limit: 1, order: [:post_id.desc]).first.post_id rescue 0
  end

  def self.posts_by_page(page=1, order='desc') 
    the_order = order.eql?('desc')? [:post_id.desc] : [:post_id.asc]
    Post.all( limit: Post.per_page, 
              conditions: ['type is NULL'], 
              offset: Post.calc_offset(page), 
              order: the_order)
  end

  def self.translated_posts_by_page(page=1, order='desc') 
    the_order = order.eql?('desc')? [:post_id.desc] : [:post_id.asc]
    Post.all( limit: Post.per_page, 
              type: 'translated', 
              offset: Post.calc_offset(page), 
              order: the_order)
  end

  def self.post_by_id(post_id)
    Post.first(post_id: post_id.to_i)
  end

  def self.calc_offset(page)
    (page - 1) * Post.per_page
  end

  def self.length_of(post_type = '')
    if post_type.downcase.eql?('translated')
      Post.count(conditions: ['type = ?', 'translated'])
    else 
      Post.count(conditions: ['type IS NULL'])
    end
  end

end
