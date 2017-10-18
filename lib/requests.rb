require 'json'
require 'net/http'
require 'openssl'
require 'uri'

module Requests
  class Error < StandardError
    attr_reader :response

    def initialize(response)
      super(response)

      @response = response
    end
  end

  CA_FILE = ENV.fetch('REQUESTS_CA_FILE',
                      File.expand_path('../cacert.pem', __FILE__))

  def self.request(method, url,
    headers: {},
    data: nil,
    params: nil,
    auth: nil,
    proxy: nil,
    options: {})

    uri = URI.parse(url)
    uri.query = encode_www_form(params) if params

    body = process_params(headers: headers, data: data) if data

    basic_auth(headers, *auth) if auth

    proxy = proxy.to_h.values_at(:host, :port, :user, :password)
    response = Net::HTTP.start(uri.host, uri.port, *proxy, opts(uri, options)) do |http|
      http.send_request(method, uri, body, headers)
    end

    Response.new(response.code, response.message, response.to_hash, response.body)
  end

private
  def self.encode_www_form(params)
    URI.encode_www_form(params)
  end

  def self.opts(uri, options)
    if uri.scheme == 'https'
      { use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        ca_file: CA_FILE,
        read_timeout: options[:read_timeout],
        open_timeout: options[:open_timeout],
      }
    end
  end

  def self.basic_auth(headers, user, pass)
    headers['Authorization'] = 'Basic ' + ["#{user}:#{pass}"].pack('m0')
  end

  def self.process_params(headers: nil, data: nil)
    if not data.kind_of?(Enumerable)
      data
    else
      headers['content-type'] = 'application/x-www-form-urlencoded'

      encode_www_form(data)
    end
  end

  class Response
    attr :status
    attr :message
    attr :headers
    attr :body

    def initialize(status, message, headers, body)
      @status, @message, @headers, @body = Integer(status), message, headers, body
    end

    # TODO Verify that JSON can parse data without encoding stuff
    def json
      JSON.parse(@body)
    end

    # TODO Verify that this is based on content-type header
    def encoding
      @body.encoding
    end

    # TODO this will probably do something related to encoding if necessary
    def text
      @body
    end

    def raise_for_status(status=nil)
      if status == nil || @status == status
        if @status < 300 && status != nil
          err_msg = "%d %s" % [@status,@message]
        elsif 300 <= @status && @status < 400
          err_msg = "Redirection: %d %s" % [@status,@message]
        elsif 400 <= @status && @status < 500
          err_msg = "Client Error: %d %s" % [@status,@message]
        elsif 500 <= @status && @status < 600
          err_msg = "Server Error: %d %s" % [@status,@message]
        end
      end

      if err_msg != nil
        raise Error, err_msg
      end
    end

  end
end
