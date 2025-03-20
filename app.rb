require 'sinatra'
require 'sinatra/reloader' if development?
require './models'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'dotenv/load'
require 'rack/protection'
require 'httparty'
require 'nokogiri'
require 'time'

enable :sessions

###### Google login認証 #######

use Rack::Protection::AuthenticityToken
set :session_secret, ENV['SESSION_SECRET']

use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], 
  scope: 'email,profile'
end

get '/' do
  @stylesheet = 'index.css'
  erb :index
end

post '/signin' do
  redirect('/auth/google_oauth2')
end

get '/auth/google_oauth2/callback' do
  auth = request.env['omniauth.auth']

  @user = User.find_or_create_by(google_id: auth['uid']) do |user|
    user.name = auth.info.name
    user.email = auth.info.email
    user.avatar_url = auth.info.image
  end
  
  session[:user_id] = @user.id
  
  erb :mypage
end

get '/mypage' do
  if session[:user_id]
    @user = User.find_by(id:session[:user_id])
    erb :mypage
  else
    erb :require
  end
end

get '/mypage/register' do
  erb :register, locals: { form_action: '/mypage/register' }
end

post '/mypage/register' do
  first_name = params[:first_name]
  last_name = params[:last_name]
  full_name = last_name + first_name
  birth_day = params[:birth_date]
  
  locality = params['locality']
  city = params['city']
  state = params['state']
  postal_code = params['postal_code']
  country_of_origin = params['country_of_origin']
  
  phone = params[:phone]
  email = params[:email]
  age = params[:age]
  gender = params['gender']
  
  # ログイン中のユーザーを取得
  user = User.find_by(id: session['user_id'])

  # ユーザーに関連するPersonを探す
  person = user.person || Person.new

  # Personレコードを更新または作成
  person.update(
    fullname: full_name,
    given_name: first_name,
    family_name: last_name,
    sex: gender,
    date_of_birth: birth_day,
    age: age,
    home_street: locality,
    home_city: city,
    home_state: state,
    home_postal_code: postal_code,
    home_country: country_of_origin
  )
  
  user.update(person_id: person.id)
  redirect '/mypage'
end



get '/signout' do
  session.clear
  redirect '/'
end

get '/auth/failure' do
  error_message = session.delete(:error) || "認証に失敗しました。"
  erb :auth_failure, locals: { error_message: error_message }
end


get '/test' do
  @stylesheet = 'output.css'
  erb :test
end

######## Google Person finder ###########

api_key = ENV['PERSON_FINDER_API_KEY']
repository = ENV['REPOSITORY']

get '/personfinder' do
  feed_url = "https://www.google.org/personfinder/#{repository}/feeds/person?key=#{api_key}"
  
  response = HTTParty.get(feed_url)
  
  if response.success?
    content_type :json
    response.body
  else
    status 500
    { error: 'データの取得に失敗しました' }.to_json
  end
end

get '/persons' do
  
  if session[:user_id].nil?
    puts "User not logged in (session[:user_id] is nil)"
    return erb :require
  end
  
  @user = User.find_by(id: session[:user_id])
  if @user.nil?
    return erb :require
  end
    
  @persons = @user.persons
  @api_results = {}
  
  @persons.each do |person|
    # queryで検索するやつー
    feed_url = "https://www.google.org/personfinder/#{repository}/api/search?key=#{api_key}&q=#{person.family_name} #{person.given_name}"
    response = HTTParty.get(feed_url)
    puts response
   if response.code == 200
      xml_data = Nokogiri::XML(response.body)
      persons = []
      xml_data.xpath('//pfif:person', 'pfif' => 'http://zesty.ca/pfif/1.4').each do |node|
        notes = []
        node.xpath('pfif:note', 'pfif' => 'http://zesty.ca/pfif/1.4').each do |note_node|
          notes << {
            author: note_node.at_xpath('pfif:author_name', 'pfif' => 'http://zesty.ca/pfif/1.4')&.text,
            status: note_node.at_xpath('pfif:status', 'pfif' => 'http://zesty.ca/pfif/1.4')&.text,
            text: note_node.at_xpath('pfif:text', 'pfif' => 'http://zesty.ca/pfif/1.4')&.text,
            entry_date: note_node.at_xpath('pfif:entry_date', 'pfif' => 'http://zesty.ca/pfif/1.4')&.text
          }
        end
        persons << {
          name: node.at_xpath('pfif:full_name', 'pfif' => 'http://zesty.ca/pfif/1.4')&.text,
          contact: node.at_xpath('pfif:contact_info', 'pfif' => 'http://zesty.ca/pfif/1.4')&.text,
          description: node.at_xpath('pfif:description', 'pfif' => 'http://zesty.ca/pfif/1.4')&.text,
          notes: notes
        }
      end
      # persons 配列が空でない場合のみ格納
      @api_results[person.fullname] = persons unless persons.empty?
    else
      @api_results[person.fullname] = []
    end
  end
  
  erb :persons_list
end  


get '/person/register' do
  erb :register, locals: { form_action: '/person/register' }
end

post '/person/register' do
  if session[:user_id]
    @user = User.find_by(id:session[:user_id])
  else
    erb :require
  end
  first_name = params[:first_name]
  last_name = params[:last_name]
  full_name = last_name + first_name
  birth_day = params[:birth_date]
  
  locality = params['locality']
  city = params['city']
  state = params['state']
  postal_code = params['postal_code']
  country_of_origin = params['country_of_origin']
  
  phone = params[:phone]
  email = params[:email]
  age = params[:age]
  gender = params['gender']
  
  persons = Person.create(
    fullname: full_name,
    given_name:  first_name,
    family_name: last_name,
    sex: gender,
    date_of_birth: birth_day,
    age: age,
    home_street: locality,
    home_city: city,
    home_state: state,
    home_postal_code: postal_code,
    home_country: country_of_origin,
    user_id: @user.id
  )
  
  redirect '/persons'
end


get '/person/fetch' do
  #古い順に取れる
  # feed_url = "https://www.google.org/personfinder/test/feeds/person?key=#{api_key}"
  query = params[:query]
  # queryで検索するやつー
  feed_url = "https://www.google.org/personfinder/#{repository}/api/search?key=#{api_key}&q=#{query}"
  
  response = HTTParty.get(feed_url)
  if response.code == 200
    @results = response
    puts @results
    erb :test
  else
    @error = "Error: #{response.code}"
    erb :error
  end
end

post '/person/post' do
  
  user = User.find_by(id: session[:user_id]) 
  person = user.person
  person_record_id = "testkey.personfinder.google.org/1223"
  note_record_id = "testkey.personfinder.google.org/1223.1"
  author_name = user.name
  
  status = "is_note_author"
  note_text = params[:statusText]
  source_date = Time.now.utc.iso8601
  if person
    full_name = person.family_name + ' ' + person.given_name
  else
    puts "error!"
  end
  
  xml_data = <<~XML
  <?xml version="1.0" encoding="utf-8"?>
  <pfif:pfif xmlns:pfif="http://zesty.ca/pfif/1.4">
    <pfif:person>
      <pfif:person_record_id>#{person_record_id}</pfif:person_record_id>
      <pfif:source_date>#{source_date}</pfif:source_date>
      <pfif:full_name>#{full_name}</pfif:full_name>
    </pfif:person>
    <pfif:note>
      <pfif:note_record_id>#{note_record_id}</pfif:note_record_id>
      <pfif:person_record_id>#{person_record_id}</pfif:person_record_id>
      <pfif:author_name>#{author_name}</pfif:author_name>
      <pfif:source_date>#{source_date}</pfif:source_date>
      <pfif:status>#{status}</pfif:status>
      <pfif:text>#{note_text}</pfif:text>
    </pfif:note>
  </pfif:pfif>
  XML
  
  response = HTTParty.post(
    "https://www.google.org/personfinder/test/api/write?key=#{api_key}",
    body: xml_data,
    headers: { 'Content-Type' => 'application/xml' }
  )
  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"
  
  redirect '/'
end
