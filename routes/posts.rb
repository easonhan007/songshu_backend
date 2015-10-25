get '/api/posts' do
  content_type :json
  page = params[:page].to_i
  page = 1 if page == 0
  order = params[:order] || 'desc'

  lasted_post_id = Post.lasted_post_id
  etag Digest::MD5.hexdigest(lasted_post_id.to_s)

  posts = Post.posts_by_page(page, order)
  posts.to_json(only: Post.basic_info_return_fields)
end

get '/api/translated_posts' do
  content_type :json
  page = params[:page].to_i
  page = 1 if page == 0
  order = params[:order] || 'desc'

  lasted_translated_post_id  = Post.lasted_translated_post_id
  etag Digest::MD5.hexdigest(lasted_translated_post_id.to_s)

  posts = Post.translated_posts_by_page(page, order)
  posts.to_json(only: Post.basic_info_return_fields)
end

get '/api/posts/count' do
  content_type :json
  type = params[:type] || ''
  length = Post.length_of(type)
  
  {count: length}.to_json  
end

get '/api/posts/:id' do
  content_type :json
  t = Post.post_by_id(params[:id])
  halt 404 if t.nil?

  etag Digest::MD5.hexdigest(params[:id].to_s)
  t.to_json(only: Post.article_return_fields)
end


  

