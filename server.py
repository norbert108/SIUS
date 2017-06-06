import os

from flask import Flask
from flask_restful import Resource, Api, reqparse

import urllib.parse as urlparse

from sius_server.DBAdapter import DBAdapter

app = Flask(__name__)
api = Api(app)

objects = dict()
taken_ids = set()


parser = reqparse.RequestParser()
parser.add_argument('id', type=int)
parser.add_argument('lat', type=float)
parser.add_argument('long', type=float)


url = urlparse.urlparse(os.environ['DATABASE_URL'])
dbname = url.path[1:]
user = url.username
password = url.password
host = url.hostname
port = url.port

db_adapter = DBAdapter(dbname, user, password, host, port)


class CoordinatorRunner(Resource):
    def get(self):
        args = parser.parse_args()
        object_id = args['id']
        result = db_adapter.get_positions(object_id)
        return {'coords': result}


class UpdateRunner(Resource):
    def put(self):
        args = parser.parse_args()
        object_id = args['id']
        lat = args['lat']
        long = args['long']
        result = db_adapter.update_position(object_id, lat, long)
        status = 200 if result == 1 else 400
        return status


class InitialiseRunner(Resource):
    def get(self):
        new_id = db_adapter.get_id()
        return {'id': new_id}


api.add_resource(CoordinatorRunner, '/coords')
api.add_resource(UpdateRunner, '/update')
api.add_resource(InitialiseRunner, '/initialise')


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)

