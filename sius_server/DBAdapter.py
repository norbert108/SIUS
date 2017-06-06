from ast import literal_eval

import psycopg2


class DBAdapter:

    def __init__(self, dbname, user, password, host, port):
        self.dbname = dbname
        self.user = user
        self.password = password
        self.host = host
        self.port = port

    def __open_connection(self):
        # self.conn = connect('dbname=%s user=%s' % (self.db_name, self.user))
        self.conn = psycopg2.connect(dbname=self.dbname, user=self.user,
                                     password=self.password, host=self.host, port=self.port)
        self.cur = self.conn.cursor()
        return self.cur

    def __close_connection(self):
        self.conn.commit()
        self.cur.close()
        self.conn.close()

    def get_id(self):
        cur = self.__open_connection()
        cur.execute('select api.sign_in_simple();')
        result = cur.fetchone()[0]
        self.__close_connection()
        return result

    def update_position(self, object_id, latitude, longitude):
        cur = self.__open_connection()
        cur.execute('SELECT api.update_position_simple(%s, %s, %s);' % (object_id, latitude, longitude))
        result = cur.fetchone()[0]
        self.__close_connection()
        return result

    def get_positions(self, object_id):
        cur = self.__open_connection()
        cur.execute('SELECT api.get_positions_simple(%s);' % object_id)
        result = cur.fetchall()
        result_set = dict()
        for record in result:
            coord = literal_eval(record[0])
            id, lat, long = coord
            result_set[id] = [lat, long]
        self.__close_connection()
        return result_set

    def test(self):
        cur = self.__open_connection()
        cur.execute('select * from core.sius_positions;')
        result = cur.fetchall()
        self.__close_connection()
        return result
