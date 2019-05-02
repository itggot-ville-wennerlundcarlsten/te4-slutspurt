require 'sinatra'
require 'pg'

get '/' do
  conn = Connection.conn
  list = []
  conn.exec('SELECT * FROM snus') do |result|
    result.each do |row|
      # puts row
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
  @username = params[:username]
  @email = params[:email]
  @password = BCrypt::Password.create(params[:password])
  p @password
  p params[:password]
  erb :index
end

post '/save_snus' do
  conn = Connection.conn
  @snusname = params[:name]
  @filename = params[:file] [:filename]
  file = params[:file] [:tempfile]
  @brandid = params[:brand]
  byebug
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
  conn = Connection.conn
  distributors = []
  brands = []
  # distributor = Distributor.get()# { {join: 'brand'}}
  distributors = Distributor.all { { join: 'brand', on: 'distributorid' } } # SELECT * FROM distributors
  distributors.each do |result|
    p result
    brands << result
  end
  erb :add_snus, locals: { brands: brands }
end

get '/snus/:id' do
  test = params[:id]
  puts test
  kalle = ''
  conn = Connection.conn
  conn.exec("SELECT * FROM snus WHERE id = #{test}") do |result|
    result.each do |row|
      kalle = row
    end
  end
  puts kalle
  erb :snus, locals: { kalle: kalle }
end
