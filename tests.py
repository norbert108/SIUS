# from urllib.parse import urlencode
# import http.client
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from tornado import gen, ioloop
from tornado.httpclient import HTTPRequest, HTTPClient, AsyncHTTPClient

import testing.postgresql
from sqlalchemy import create_engine
import unittest

# url = 'https://localhost:8888'
# headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/plain"}
#
# query_req_body = urlencode({
#     'latitude': 28.30,
#     'longitude': 45.38,
#     'radius': 15.3
# })
# connect_req_body = urlencode({'name': 'testuser'})


# def handle_response(response):
#     if response.error:
#         print("Error: %s" % response.error)
#     else:
#         print(response.body)

# http_client = HTTPClient()
# conn_request = HTTPRequest(url=url, method='POST', headers=headers, body=connect_req_body)
# response = http_client.fetch(conn_request)
# print('req')
# print(response.body)
# print(str(response))


# conn = http.client.HTTPConnection('localhost', 8888)
# conn.request('POST', '/connect', body=connect_req_body, headers=headers)
# resp = conn.getresponse()
# print(resp.read())
#
# conn.request('POST', '/query', body=query_req_body, headers=headers)
# resp = conn.getresponse()
# print(resp.read())


import psycopg2


class TestDatabase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # connect to PostgreSQL
        cls.conn = psycopg2.connect("dbname=sius_2017 user=postgres")
        cls.cursor = cls.conn.cursor()

        cls.test_obj_uuid1 = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
        cls.test_obj_uuid2 = "b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"

    def setUp(self):
        self.cursor.execute("DELETE FROM core.sius_objects")
        self.cursor.execute("SELECT setval('core.sius_objects_obj_id_seq', 1)")
        self.conn.commit()

    def test_sign_in_new(self):
        expected_result = [(2, "test_obj_name", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid1)]

        param_list = ["test_obj_name", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid1]
        self.cursor.callproc("api.sign_in", param_list)
        self.conn.commit()
        procedure_retval = self.cursor.fetchone()

        self.cursor.execute("SELECT * FROM core.sius_objects")
        actual_result = self.cursor.fetchall()

        self.assertListEqual(actual_result, expected_result)
        self.assertEqual(procedure_retval, (2,))

    def test_sign_in_existing(self):
        expected_result = [(2, "test_obj_name", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid1)]

        param_list = ["test_obj_name", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid1]
        self.cursor.callproc("api.sign_in", param_list)
        self.cursor.callproc("api.sign_in", param_list)
        self.conn.commit()
        procedure_retval = self.cursor.fetchone()

        self.cursor.execute("SELECT * FROM core.sius_objects")
        actual_result = self.cursor.fetchall()

        self.assertListEqual(actual_result, expected_result)
        self.assertEqual(procedure_retval, (2,))

    def test_sign_in_two(self):
        expected_result = [(2, "test_obj_name", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid1),
                           (3, "test_obj_name", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid2)]

        param_list = ["test_obj_name", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid1]
        self.cursor.callproc("api.sign_in", param_list)
        param_list = ["test_obj_name", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid2]
        self.cursor.callproc("api.sign_in", param_list)
        self.conn.commit()
        procedure_retval = self.cursor.fetchone()

        self.cursor.execute("SELECT * FROM core.sius_objects")
        actual_result = self.cursor.fetchall()

        self.assertListEqual(actual_result, expected_result)
        self.assertEqual(procedure_retval, (3,))

