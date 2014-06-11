require 'sinatra'
require 'rest_client'

sf_client_id = ENV['SF_CLIENT_ID']
sf_client_secret = ENV['SF_CLIENT_SECRET']
sf_redirect_uri = ENV['SF_REDIRECT_URI']

SF_AUTHZ_URL = "https://login.salesforce.com/services/oauth2/authorize"
SF_TOKEN_URL = "https://login.salesforce.com/services/oauth2/token"

get '/' do
  "<a href=\"/connect\">Login to Salesforce</a>"
end

get '/login' do
  authz_url = SF_AUTHZ_URL +
    "?response_type=code" +
    "&client_id=" + sf_client_id +
    "&redirect_uri=" + sf_redirect_uri +
    "&scope=api"
    # Set state parameter and check in callback to prevent attack in production
    # "&state=xxxxxx"
  redirect authz_url
end

get '/callback' do
  code = params[:code]
  response = RestClient.post SF_TOKEN_URL, { 
    :grant_type => "authorization_code",
    :code => code,
    :client_id => sf_client_id,
    :client_secret => sf_client_secret,
  }.to_json, :content_type => :json, :accept => :json

  result = JSON.parse(response.to_str)
  access_token = result.access_token
  instance_url = result.instance_url
  chatter_profile_url = instance_url + "/services/data/29.0/chatter/users/me"

  response = RestClient.get chatter_profile_url, :accept => :json, :authorization => "Bearer #{access_token}"
  profile = JSON.parse(response.to_str)
  "Hello, #{profile.name}"

end


