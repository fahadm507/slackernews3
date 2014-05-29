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

def check_title_and_description(params)
  if params[:title] == nil
    @errors << "Title can't be empty"
  end
  if params[:description] == nil
    @errors << "You need to add description"
  elsif params[:description].length < 20
    @errors << "description can't be less than 20 characters"
  end
end
#this method checks if url is valid or not
def check_submissions(url)
  url = url.downcase
  if url.include?("http://www.")
    valid_url?(url) ? url : false
  elsif url.include?("www.")
    valid_url?(url.insert(0,"http://")) ? url : false
  else
    valid_url?(url.insert(0,"http://www.")) ? url : false
  end
end

def valid_url?(url)
  begin
    Net::HTTP.get_response(URI(url)).code == "200" ? true : false
  rescue SocketError
    false
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

post '/articles/new' do
  check_to_url = check_submissions(params[:url])
    if check_to_url == false
      @errors << "your url is not valid"
    else
      save_post(params)
    end

redirect '/articles'
end

get '/articles/new' do
  @errors = []
  erb :show
end
