require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "ruby-debug"
require 'cgi'

message = "Message from Ruby" ## Message to be Sent
number = '' # Receiver mobile number
cookies_jar = Array.new
referer_jar = Array.new
url = URI.parse('http://site5.way2sms.com')
regex = /http:\/\/site5.way2sms.com\/(.+)/
def set_header(cookies_jar,referer_jar)
  headers = {}
  cookies_jar.compact!
  unless cookies_jar.last.nil? 
    headers = {
    "Cookie" => cookies_jar.last,
    "Referer" => referer_jar.last,
    "Content-Type" => "application/x-www-form-urlencoded",
 "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0"
}
  else
   headers = {
    "Referer" => referer_jar.last,
    "Content-Type" => "application/x-www-form-urlencoded",
 "User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0"
      }
 end     
 return headers
end

res = Net::HTTP.start(url.host,url.port) do |http|
  http.get('/content/index.html')
end

cookies_jar << res['set-cookie']
referer_jar << "http://site5.way2sms.com/content/index.html"



headers =  set_header(cookies_jar,referer_jar)

username = '' ## way2sms login
password = '' ## way2sms password

data = 'username='+username+'&password='+password+'&Submit=Sign+in'


res = Net::HTTP.start(url.host,url.port) do |http| 
  http.post('/auth.cl',data,headers)
end
 cookies_jar << res['set-cookie']
 headers = set_header(cookies_jar,referer_jar)
 path = ''
 redirect_to = ''
 if !(res["location"].nil?) && (res.code.to_i > 299 &&  res.code.to_i < 400)
   path = res['location'].match(regex)[1] 
   redirect_to =  res['location']
 end
 
if !(res["location"].nil?) && (res.code.to_i > 299 && res.code.to_i < 400)
   res = Net::HTTP.start(url.host,url.port) do |http|
   http.get(path,headers)
   end
end      
     
cookies_jar << res['set-cookie'] 
   if redirect_to.empty?
      referer_jar << "http://site5.way2sms.com/content/index.html"
   else
      referer_jar << redirect_to 
   end
redirect_to = ''
path = ''      
headers =  set_header(cookies_jar,referer_jar)


#res = Net::HTTP.start(url.host,url.port) do |http|
#  http.get('/jsp/Main.jsp?id=87C4C2740DE67329769EC424E6C6B943.b501',headers)
#end  


cookies_jar << res['set-cookie']
referer_jar << "http://site5.way2sms.com/jsp/InstantSMS.jsp?val=0"
headers = set_header(cookies_jar,referer_jar)
message = CGI.escape(message)
sms_data = 'custid=undefined&HiddenAction=instantsms&Action=hgfgh5656fgd&login=&pass=&MobNo='+number+'&textArea='+message


res = Net::HTTP.start(url.host,url.port) do |http|
  http.post('/FirstServletsms?custid=',sms_data,headers)
end

 if !(res["location"].nil?) && (res.code.to_i > 299 &&  res.code.to_i < 400)
   path = res['location'].match(regex)[1] 
   redirect_to =  res['location']
 end
 
if !(res["location"].nil?) && (res.code.to_i > 299 && res.code.to_i < 400)
   res = Net::HTTP.start(url.host,url.port) do |http|
   http.get(path,headers)
  end
end   
   
#referer_jar << "http://site5.way2sms.com/jsp/Main.jsp?id=87C4C2740DE67329769EC424E6C6B943.b501"
#cookies_jar << res['set-cookie']
#headers  = set_header(cookies_jar,referer_jar)
#res = Net::HTTP.start(url.host,url.port) do |http|
#  http.get('/jsp/Main.jsp?id=87C4C2740DE67329769EC424E6C6B943.b501',headers)
#end  
#puts res.body
puts "SMS Sent !!!"
