from random import randint


class Database:

    _users_tmp = list()

    @classmethod
    def initialize(cls):
        for i in range(1, 21):
            user = dict()
            user['pos_id'] = i
            user['latitude'] = randint(50030, 50090) / 1000.0
            user['longitude'] = randint(19900, 20010) / 1000.0
            cls._users_tmp.append(user)

    @classmethod
    def query(cls, latitude, longitude, radius):
        # users_nearby = {
        #     'hahaha': (45.3, 66.6),
        #     'jajaja': (-53.2, 43.6),
        #     'xaxaxa': (40.2, 5.6)
        # }
        # return users_nearby
        cls.modify_positions()
        return cls._users_tmp

    @classmethod
    def modify_positions(cls):
        for user in cls._users_tmp:
            switch_x = (randint(10) - 5) / 1000.0
            user['longitude'] = user['longitude'] + switch_x
            switch_y = (randint(10) - 5) / 1000.0
            user['latitude'] = user['latitude'] + switch_y
