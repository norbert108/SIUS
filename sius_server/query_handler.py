from sius_server.base_handler import BaseHandler
from sius_server.database_handler import Database


class QueryHandler(BaseHandler):

    def post(self):
        # if not self.current_user:
        #     self.write("login required")
        #     return
        latitude = self.get_argument('latitude')
        longitude = self.get_argument('longitude')
        radius = self.get_argument('radius')
        self.write(Database.query(latitude, longitude, radius))
