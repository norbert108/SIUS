# -*- coding: utf-8 -*-
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.web import Application

from sius_server.database_handler import Database
from sius_server.login_handler import LoginHandler
from sius_server.query_handler import QueryHandler

import os


application = Application([
    (r"/query", QueryHandler),
    (r"/connect", LoginHandler)
])
Database.initialize()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8888))
    http_server = HTTPServer(application)
    http_server.listen(port)
    IOLoop.instance().start()
