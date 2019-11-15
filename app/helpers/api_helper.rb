module ApiHelper

  require "uri"
  require "net/http"
  # response.is_a?(Net::HTTPSuccess) &&
  def api_request(url, method, params = nil)
    uri = URI.parse(ENV['SERVER_API'] + url)
    req = if method == 'post' || method == 'update'
            Net::HTTP::Post.new(uri)
          elsif method == 'patch'
            Net::HTTP::Patch.new(uri)
          elsif method == 'get'
            Net::HTTP::Get.new(uri)
          else
            Net::HTTP::Delete.new(uri)
          end
    header = get_headers
    req['access-token'] = header["access-token"]
    req['uid'] = header["uid"]
    req['client'] = header["client"]
    req.form_data = JSON.parse(params) unless params.nil?

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