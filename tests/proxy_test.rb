require 'requests/sugar'
require 'webrick'
require 'webrick/httpproxy'
require 'thread'
require 'logger'

port = ENV.fetch("PROXY_PORT", 8000)

setup do
  WEBrick::HTTPProxyServer.new(
    ServerName: "0.0.0.0",
    Port: port,
    Logger: Logger.new("/dev/null"),
    AccessLog: []
  )
end

test 'request via proxy' do |proxy|
  Thread.new { proxy.start }

  r = Requests.get('http://httpbin.org/get', params: { foo: 'bar' }, proxy: {
    host: '0.0.0.0', port: port
  })

  assert_equal 200, r.status
  assert_equal ['application/json'], r.headers['content-type']
  assert(r.json['args'] && r.json['args']['foo'] == 'bar')

  assert_equal ["1.1 vegur, 1.1 0.0.0.0:#{port}"], r.headers['via']

  proxy.shutdown
end
