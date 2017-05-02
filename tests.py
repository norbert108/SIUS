from urllib.parse import urlencode
import http.client

url = 'https://localhost:8888'
headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/plain"}

query_req_body = urlencode({
    'latitude': 28.30,
    'longitude': 45.38,
    'radius': 15.3
})
connect_req_body = urlencode({'name': 'testuser'})


def handle_response(response):
    if response.error:
        print("Error: %s" % response.error)
    else:
        print(response.body)

conn = http.client.HTTPConnection('localhost', 8888)
conn.request('POST', '/connect', body=connect_req_body, headers=headers)
resp = conn.getresponse()
print(resp.read())

conn.request('POST', '/query', body=query_req_body, headers=headers)
resp = conn.getresponse()
print(resp.read())

