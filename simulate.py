import requests
import json
import random
import time

url = 'https://sius.herokuapp.com'
min_lat = 50.075214
max_lat = 50.057347
min_long = 19.903518
max_long = 19.958745
max_diff = 0.001


class Simulate:

    def __init__(self):
        self.user_data = {}

    def initialize_users(self, users_count=20):
        for i in range(users_count):
            uid = Simulate.do_initialize()
            self.user_data[uid] = None
            self.update_coords(uid)

    def run(self, time_delay=3):
        while True:
            time.sleep(time_delay)
            for uid in self.user_data.keys():
                self.update_coords(uid)

    def update_coords(self, uid):
        if self.user_data.get(uid) is None:
            random_coords = Simulate.get_random_coords()
        else:
            random_coords = Simulate.get_random_coords_diff(self.user_data.get(uid)[0], self.user_data.get(uid)[1])

        Simulate.do_update(uid, random_coords[0], random_coords[1])
        self.user_data[uid] = random_coords
        print("Coords for {0} updated: {1}, {2}".format(uid, random_coords[0], random_coords[1]))

    @staticmethod
    def get_random_coords():
        return random.uniform(min_lat, max_lat), random.uniform(min_long, max_long)

    @staticmethod
    def get_random_coords_diff(prev_lat, prev_long):
        return prev_lat + random.uniform(0, max_diff), prev_long + random.uniform(0, max_diff)

    @staticmethod
    def do_initialize():
        result = json.loads(requests.get(url + '/initialise').text)
        return result['id']

    @staticmethod
    def do_update(uid, lat, long):
        requests.put(url + '/update', data={'id': uid, 'lat': lat, 'long': long})

sim = Simulate()
sim.initialize_users(users_count=20)
sim.run(time_delay=3)
