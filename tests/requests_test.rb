require 'requests/sugar'

test 'basic auth' do
  r = Requests.get('http://httpbin.org/basic-auth/u/p', auth: ['u', 'p'])

  assert_equal r.json['authenticated'], true
  assert_equal r.json['user'], 'u'
end

test 'GET' do
  r = Requests.get('http://httpbin.org/get', params: { foo: 'bar' })

  assert_equal 200, r.status
  assert_equal ['application/json'], r.headers['content-type']
  assert_equal 'UTF-8', r.encoding.to_s

  assert(r.json['args'] && r.json['args']['foo'] == 'bar')
end

test 'POST data' do
  r = Requests.post('http://httpbin.org/post', data: { "plan" => "test" })

  assert_equal 200, r.status
  assert_equal ['application/json'], r.headers['content-type']
  assert_equal 'UTF-8', r.encoding.to_s

  assert(r.json['form'] && r.json['form'] == { 'plan' => 'test' })
end

test 'PUT data' do

end

test 'POST params' do
  payload = [
    ['a[]', 'a1'],
    ['a[]', 'a2'],
    ['b', '3'],
    ['c', '4']
  ]

  r = Requests.post('http://httpbin.org/post', data: payload)

  assert_equal 200, r.status

  form = r.json['form']

  assert_equal form['a[]'], ['a1', 'a2']
  assert_equal form['b'], '3'
  assert_equal form['c'], '4'
end

test 'Error' do
  begin
    Requests.post('http://httpbin.org/something')
  rescue Requests::Error => e
    assert_equal Net::HTTPNotFound, e.response.class

    assert_equal Hash, e.headers.class
    assert_equal String, e.body.class
    assert_equal 404, e.status
  end
end

test 'read timeout' do
  begin
    Requests.get('http://httpbin.org:10000', options: { read_timeout: 1 })
  rescue => err
    assert err.kind_of?(Errno::ECONNREFUSED)
  end
end

test 'read timeout not failing' do
  begin
    Requests.get('http://httpbin.org/get', options: { read_timeout: 30 })
  rescue => err
    flunk(err)
  end
end

test 'open timeout' do
  begin
    Requests.get('http://httpbin.org:10000', options: { open_timeout: 1 })
  rescue => err
    assert err.kind_of?(Errno::ECONNREFUSED)
  else
    flunk("expected exception")
  end
end

test 'open timeout not failing' do
  begin
    Requests.get('http://httpbin.org/get', options: { open_timeout: 30 })
  rescue => err
    flunk(err)
  end
end
