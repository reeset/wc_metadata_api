module WC_METADATA_API
   class Helper
     attr_accessor :debug_string
     attr_accessor :wskey, :secret, :principalID, :principalDNS

     def initialize(options={})
        @wskey = options[:wskey]
        @secret = options[:secret]
        @principalID = options[:principalID]
        @principalDNS = options[:principalDNS]
     end

 
     def MakeHTTPRequest(opts={})
	@debug_string = ""

	   token = OCLC::Auth::WSKey.new(@wskey, @secret)
	   uri = URI.parse(opts[:url])
           request = Net::HTTP::Get.new(uri.request_uri)
	   request['Authorization'] =token.hmac_signature('GET', opts[:url], :principal_id => @principalID, :principal_idns => @principalDNS)
	   request['Content-Type'] = 'application/atom+xml'
	   http = Net::HTTP.new(uri.host, uri.port)
	   http.use_ssl = true
	   response = http.start do |http|
	      http.request(request)
	   end
	   return response.body
     end

     def MakeHTTP_POST_PUT_Request(opts={})
        @debug_string = ""
           token = OCLC::Auth::WSKey.new(@wskey, @secret)
           uri = URI.parse(opts[:url])
	   request = nil
           if opts[:method] == "POST"
	     request = Net::HTTP::Post.new(uri.request_uri)
	   elsif opts[:method] == "PUT"
	     request = Net::HTTP::Put.new(uri.request_uri)
	   elsif opts[:method] == "DELETE"
	     request = Net::HTTP::Delete.new(uri.request_uri)
	   end 
           request['Authorization']=token.hmac_signature(opts[:method], opts[:url], :principal_id => @principalID, :principal_idns => @principalDNS) 
           request['Content-Type'] = 'application/vnd.oclc.marc21+xml'
	   request['Accept'] = 'application/atom+xml'
	   http = Net::HTTP.new(uri.host, uri.port)
           http.use_ssl = true
	   request.body = opts[:xRecord]
           response = http.start do |http|
	       http.request(request)
	   end
           return response
      end
   end
end
