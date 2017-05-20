from sius_server.base_handler import BaseHandler


class LoginHandler(BaseHandler):

    def post(self):
        user_name = self.get_argument("name")
        self.set_cookie("user", user_name)
        result = "logged in as %s" % user_name
        self.write(result)
        # return result
