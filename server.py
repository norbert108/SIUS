# -*- coding: utf-8 -*-
import tornado.web
import tornado.httpserver
import tornado.ioloop


class Database:
    @staticmethod
    def query(latitude, longitude, radius):
        users_nearby = {
            'hahaha': (45.3, 66.6),
            'jajaja': (-53.2, 43.6),
            'xaxaxa': (40.2, 5.6)
        }
        return users_nearby


class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        return self.get_cookie("user")


class LoginHandler(BaseHandler):
    def post(self):
        user_name = self.get_argument("name")
        self.set_cookie("user", user_name)
        self.write("logged in as %s" % user_name)


class QueryHandler(BaseHandler):
    def post(self):
        # if not self.current_user:
        #     self.write("login required")
        #     return
        latitude = self.get_argument('latitude')
        longitude = self.get_argument('longitude')
        radius = self.get_argument('radius')
        self.write(Database.query(latitude, longitude, radius))

application = tornado.web.Application([
    (r"/query", QueryHandler),
    (r"/connect", LoginHandler)
])

if __name__ == "__main__":
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
