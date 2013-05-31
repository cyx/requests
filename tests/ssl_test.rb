require 'requests'

test 'ssl' do
  response = Requests.request('GET', 'https://httpbin.org/get')

  assert_equal 200, response.status_code
end
