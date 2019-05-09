require 'sinatra'
require 'pg'
set :session_secret, 'super secret'
enable :sessions

get '/' do
  conn = Connection.conn
  @user_id = session[:user_id]
  @user = session[:user]
  puts session[:user_id]
  list = []
  conn.exec('SELECT * FROM snus') do |result|
    result.each do |row|
      list << row
    end
  end
  I18n.locale = :swe if params[:lang] == 'swe'
  I18n.locale = :en if params[:lang] == 'en'
  erb :index, locals: { list: list }
end

get '/create_new_user' do
  erb :create_new_user
end

post '/create_new_user' do
  conn = Connection.conn
  @username = params[:username]
  @email = params[:email]
  @password = BCrypt::Password.create(params[:password])
  p @password
  p params[:password]
  conn.exec("INSERT INTO userinfo
    (username, email, password)
    VALUES
    ('$1', '$2', '$3')",
            [@username, @email, @password])
  redirect '/'
end

post '/login' do
  conn = Connection.conn
  @email = params[:email]
  @password = params[:password]
  kalle = conn.exec('SELECT * FROM userinfo WHERE email = $1', [@email]).first # skydda mot sql injection
  user = BCrypt::Password.new(kalle['password'])
  if user == params[:password]
    session[:user_id] = kalle['id']
    session[:user] = kalle['username']
  end
  puts session[:user_id]
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

post '/save_snus' do
  conn = Connection.conn
  @snusname = params[:name]
  @filename = params[:file] [:filename]
  file = params[:file] [:tempfile]
  @brandid = params[:brand]
  p @brandid
  insert_snus(params, @filename, @brandid)
  newsnus = nil
  conn.exec("SELECT id FROM snus WHERE name = '#{@snusname}'") do |result|
    result.each do |row|
      newsnus = row['id']
    end
  end
  File.open("./public/assets/img/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
  redirect "/snus/#{newsnus}"
end

def insert_snus(
  params,
  filename,
  brandid
)
  conn = Connection.conn
  conn.exec("INSERT INTO snus
      (brandid, type, prillsize, description, taste,
      netweight, nicotinepergram, name, image)
    VALUES (
    #{brandid.to_i},
    '#{params[:type]}',
    #{params[:prillsize].to_f},
    '#{params[:description]}',
    '#{params[:taste]}',
    #{params[:netweight].to_f},
    #{params[:nicotinepergram].to_i},
    '#{params[:name]}',
    '#{filename}')")
end

get '/add_snus' do
  brands = []
  # distributor = Distributor.get()# { {join: 'brand'}}
  distributors = Distributor.all do
    {
      join: 'brand', on: 'distributorid'
    }
  end; # SELECT * FROM distributors
  distributors.each do |result|
    p result
    brands << result
  end
  erb :add_snus, locals: { brands: brands }
end

post '/add_rating' do
  @stars = params[:stars]
  @user_id = session[:user_id]
  @snus_id = params[:snus_id]
  p @user_id
  p @stars
  p @snus_id
  conn = Connection.conn
  conn.exec("INSERT INTO rating
    (stars, userid, snusid)
    VALUES
    (#{@stars.to_i}, #{@user_id.to_i}, #{@snus_id.to_i})")
  redirect "/snus/#{@snus_id}"
end

get '/snus/:id' do
  @user_id = session[:user_id]
  @user = session[:user]
  test = params[:id]
  puts test
  conn = Connection.conn
  snus = conn.exec("SELECT * FROM snus WHERE id = #{test}").first
  ratings = []
  conn.exec("SELECT stars FROM rating where snusid = #{snus['id']}") do |result|
    result.each do |row|
      ratings << row
    end
  end
  p ratings
  p snus
  erb :snus, locals: { snus: snus, ratings: ratings }
end
