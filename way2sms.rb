require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "ruby-debug"
require 'cgi'

URL = 'http://site1.way2sms.com'
username = '' ## way2sms login
password = '' ## way2sms password
message = "Hello World :)" ## Message to be Sent
number = ''   # Receiver mobile number

## With the above change you need to provide your Action on line number
uri = URI.parse URL
URL_REGEX = /http:\/\/site1.way2sms.com\/(.+)/

def set_header(cookie=nil,referer=nil)
  {"Cookie" => cookie , "Referer" => referer ,"Content-Type" => "application/x-www-form-urlencoded","User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.3) Gecko/20091020 Ubuntu/9.10 (karmic) Firefox/3.5.3 GTB7.0" }
end

http = Net::HTTP.new(uri.host,uri.port)

if uri.scheme == "https"
   http.use_ssl = true
   http.ca_path = "/etc/ssl/certs"
   http.verify_mode = OpenSSL::SSL::VERIFY_PEER
end




def fetch(http,path,header,data=nil,method=:get,limit=10)
 raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  cookie ||= header['Cookie']
  referer ||= header['Referer']
  if method == :get
    response = http.get(path,header.delete_if {|i,j| j.nil? })
  else
    response = http.post(path,data,header.delete_if {|i,j| j.nil? })
    cookie ||= response['set-cookie']
  end

  case response.code
    when   /2\d{2}/
      return [cookie,referer,response,http]
    when  /3\d{2}/
      cookie,referer,response,http = fetch(http,("/"+response['location'].match(URL_REGEX)[1]),set_header(cookie,(URL+path)),limit-1)
      return [cookie,referer,response,http]
   else
     return "HTTP Error"
   end
end


cookie,referer = [nil,nil]

cookie,referer,response,http = fetch(http,'/content/index.html',set_header(cookie,referer))



data = 'username='+username+'&password='+password+'&Submit=Sign+in'
cookie,referer,response,http = fetch(http,'/Login1.action',set_header(cookie,referer),data,:post)


message = CGI.escape(message)

## The Action obtained from the way2sms on page after successful login  the form of the quick message submission by inespecting it using firebuglite
## Action need to be replace with yours --------
#                                              |
sms_data = 'HiddenAction=instantsms&Action=hgfgh5656fgd&MobNo='+number+'&textArea='+message

cookie,referer,response,http = fetch(http,'/quicksms.action',set_header(cookie,referer),sms_data,:post)

puts "SMS Sent !!!"
