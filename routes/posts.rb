get '/api/posts' do
  content_type :json
  page = params[:page].to_i
  page = 1 if page == 0
  order = params[:order] || 'desc'
  posts = Post.posts_by_page(page, order)
  posts.to_json(only: Post.basic_info_return_fields)
end

get '/api/posts/:id' do
  content_type :json
  t = Post.post_by_id(params[:id])
  halt 404 if t.nil?
  t.to_json(only: Post.article_return_fields)
end

# post '/api/posts' do
#   body = JSON.parse request.body.read
#   t = Post.create(title: body['title'], 
#                  description: body['description'],
#                  completed: false)
#   status 201
#   t.to_json
# end

# put '/api/posts/:id' do
#   body = JSON.parse request.body.read
#   t = Post.get(params[:id])
#   halt 404 if t.nil?
#   halt 500 unless Post.update(
#     title: body['title'], 
#     description: body['description'])

#   t.to_json
# end

# delete '/api/posts/:id' do
#   t = Post.get params[:id]
#   halt 404 if t.nil?
#   halt 500 unless t.destroy
#   t.to_json
# end
