# -*- coding: utf-8 -*-
import tornado.web
import tornado.httpserver
import tornado.ioloop


class Database:
    @staticmethod
    def query(latitude, longitude):
        locations_nearby = {
            'hahaha': (45.3, 66.6),
            'jajaja': (-53.2, 43.6),
            'xaxaxa': (40.2, 5.6)
        }
        return locations_nearby


class QueryHandler(tornado.web.RequestHandler):
    def post(self):
        latitude = self.get_argument('latitude')
        longitude = self.get_argument('longitude')
        self.write(Database.query(latitude, longitude))

application = tornado.web.Application([
    (r"/query", QueryHandler)
])

if __name__ == "__main__":
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
