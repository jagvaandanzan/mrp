module ApiHelper

  require "uri"
  require "net/http"
  # response.is_a?(Net::HTTPSuccess) &&
  def api_request(url, method, params = nil)
    uri = URI.parse(ENV['SERVER_API'] + url)
    req = if method == 'post' || method == 'update'
            Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'patch'
            Net::HTTP::Patch.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'get'
            Net::HTTP::Get.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          else
            Net::HTTP::Delete.new(uri)
          end
    header = get_headers
    req['access-token'] = header["access-token"]
    req['uid'] = header["uid"]
    req['client'] = header["client"]
    req.body = JSON.parse(params).to_json unless params.nil?

    Net::HTTP.start(uri.hostname, uri.port,
                    :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }
  end

  def api_send(url, method, params = nil)
    # puts url.to_s
    uri = URI.parse(url)
    req = if method == 'post' || method == 'update'
            Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'patch'
            Net::HTTP::Patch.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'get'
            Net::HTTP::Get.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          else
            Net::HTTP::Delete.new(uri)
          end
    req.body = JSON.parse(params).to_json unless params.nil?

    Net::HTTP.start(uri.hostname, uri.port,
                    :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }
  end

  def sent_itoms(url, method, params = nil)
    uri = URI.parse(url)
    req = if method == 'post' || method == 'update'
            Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'patch'
            Net::HTTP::Patch.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'get'
            Net::HTTP::Get.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          else
            Net::HTTP::Delete.new(uri)
          end
    req['Authorization'] = "Basic YXJpd2lzZWxsYzpNeVByb3RlY3RlZFBhc3N3b3JkMDUxNSo="
    req.body = JSON.parse(params).to_json unless params.nil?

    Net::HTTP.start(uri.hostname, uri.port,
                    :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }
  end

  def sent_market_web(url, method, params = nil)
    puts params.to_s
    uri = URI.parse(url)
    req = if method == 'post' || method == 'update'
            Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'patch'
            Net::HTTP::Patch.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          elsif method == 'get'
            Net::HTTP::Get.new(uri, 'Content-Type' => 'application/json; charset=utf-8')
          else
            Net::HTTP::Delete.new(uri)
          end

    req['X-API-TOKEN'] = "aeBdSf8fX75LQmSwfDvHRywZDwAxo6fr"
    req.body = JSON.parse(params).to_json unless params.nil?

    Net::HTTP.start(uri.hostname, uri.port,
                    :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }
  end

  private

  def get_headers
    file = File.open("config/.serv", "r")
    headers = MultiJson.load(file.read)
    file.close
    if Time.now.to_i < headers['expiry'].to_i
      headers
    else
      login
    end
  end


  def login
    params = {
        email: ENV['SERVER_UID'],
        password: ENV['SERVER_PAS']
    }

    response = Net::HTTP.post_form(URI.parse(ENV['SERVER_API'] + 'auth/sign_in'), params)

    headers = {"access-token" => '', "uid" => '', "client" => '', "expiry" => '0'}
    if response.code.to_i == 200
      headers['access-token'] = response['access-token']
      headers['uid'] = response['uid']
      headers['client'] = response['client']
      headers['expiry'] = response['expiry']

      file = File.open("config/.serv", "w")
      file.write MultiJson.dump(headers)
      file.close
      headers
    else
      headers
    end
  end
end