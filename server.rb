require 'sinatra'
require 'pry'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname:'news')
      yield(connection)
  ensure
    connection.close
  end
end

def save_post(params)
  sql= 'INSERT INTO posts (title, description, url, created_at)
        VALUES($1,$2,$3,NOW())'
  db_connection do |conn|
    conn.exec_params(sql,[params[:title],params[:description],params[:url]])
  end
end

get '/' do
  redirect '/articles'
end

get '/articles' do
  sql = 'SELECT * FROM posts'
  @posts = db_connection do |conn|
    conn.exec(sql)
  end

  erb :index
end

post '/articles' do
  save_post(params)

redirect '/articles'
end
