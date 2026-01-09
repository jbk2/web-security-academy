require 'uri'
require 'net/http'
require 'openssl'

ASCII_MIN = 32
ASCII_MAX = 126

def http_client
  http = Net::HTTP.new(BASE_URI.host, BASE_URI.port)
  http.use_ssl = (BASE_URI.scheme == "https")
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  http.open_timeout = 5
  http.read_timeout = 10
  http
end

def built_request(injected_tracking_id, session_value)
  req = Net::HTTP::Get.new(BASE_URI.request_uri)
  req["Accept"] = "text/html"
  req["Cookie"] = "TrackingId=#{injected_tracking_id}; session=#{session_value}"
  req
end

def valid_request(injected_tracking_id, session_value)
  response = http_client.request(built_request(injected_tracking_id, session_value))

  puts response.code == '200' ? "Status: ✅ #{response.code} #{response.message}" : "Status: ❌ #{response.code} #{response.message}"
  puts "Content-Type: #{response['content-type']}"
  puts "Body bytes: #{response.body.bytesize}"
  puts response.body
end


