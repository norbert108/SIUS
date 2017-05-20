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
        db_result = Database.query(latitude, longitude, radius)
        result = {
            'status': 1,
            'result': db_result
        }
        self.write(result)
