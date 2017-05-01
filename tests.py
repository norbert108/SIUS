from urllib.parse import urlencode
import tornado.httpclient
import tornado.ioloop

url = 'https://localhost:8888'
post_fields = {
    'latitude': 28.30,
    'longitude': 45.38
}
request_body = urlencode(post_fields).encode()


def handle_response(response):
    if response.error:
        print("Error: %s" % response.error)
    else:
        print(response.body)

http_client = tornado.httpclient.AsyncHTTPClient()
http_client.fetch("http://localhost:8888/query", handle_response, method='POST', body=request_body)
tornado.ioloop.IOLoop.instance().start()
