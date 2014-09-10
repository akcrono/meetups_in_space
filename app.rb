require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

#refactor in meetup class?
def valid_meetup? meetup
  if meetup["name"] == ''
    return false
  elsif meetup["location"] == ''
    return false
  elsif meetup["description"] == ''
    return false
  end
  true
end

get '/' do
  erb :index
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end

get '/meetups/create' do
  if !signed_in?
    flash[:notice] = 'Not signed in'
    redirect '/'
  end
  @meetup = params[:meetup] if params[:meetup]
  erb :'meetups/create'
end

post '/meetups/submit' do
  @meetup = params[:meetup]
  if valid_meetup?(@meetup)
    temp = Meetup.create(params[:meetup])
    redirect "/meetups/#{temp.id}"
  end
  #todo notice takes two loads

  flash.now[:notice] = 'Field blank'
  erb :'meetups/create'
end

get '/meetups/all' do
  @meetups = Meetup.all
  erb :'meetups/all'
end

get '/meetups/:meetup_id' do
  @meetup = Meetup.find(params[:meetup_id])
  @members = @meetup.users
  erb :'meetups/show'
end

post '/meetups/join/:meetup_id' do
  Signup.create(user_id: current_user.id, meetup_id: params[:meetup_id])
  redirect "/meetups/#{params[:meetup_id]}"

end

post '/meetups/leave/:meetup_id' do
  signup = current_user.signups.find_by meetup_id: params[:meetup_id]
  signup.delete
  redirect "/meetups/#{params[:meetup_id]}"

end
