import unittest
import psycopg2


class TestDatabase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # connect to PostgreSQL
        cls.conn = psycopg2.connect("dbname=sius_2017 user=postgres")
        cls.cursor = cls.conn.cursor()

        cls.test_obj_uuid1 = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
        cls.test_obj_uuid2 = "b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"

    def setUp(self):
        self.cursor.execute("DELETE FROM core.sius_positions")
        self.cursor.execute("SELECT setval('core.sius_positions_pos_id_seq', 1)")
        self.cursor.execute("DELETE FROM core.sius_objects")
        self.cursor.execute("SELECT setval('core.sius_objects_obj_id_seq', 1)")
        self.conn.commit()

    def test_sign_in_new(self):
        expected_result = [(2, "test_obj_name", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid1)]

        param_list = ["test_obj_name", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid1]
        self.cursor.callproc("api.sign_in", param_list)
        self.conn.commit()
        procedure_retval = self.cursor.fetchone()

        self.cursor.execute("SELECT * FROM core.sius_objects")
        actual_result = self.cursor.fetchall()

        self.assertListEqual(actual_result, expected_result)
        self.assertEqual(procedure_retval, (2,))

    def test_sign_in_existing(self):
        expected_result = [(2, "test_obj_name", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid1)]

        param_list = ["test_obj_name", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid1]
        self.cursor.callproc("api.sign_in", param_list)
        self.cursor.callproc("api.sign_in", param_list)
        self.conn.commit()
        procedure_retval = self.cursor.fetchone()

        self.cursor.execute("SELECT * FROM core.sius_objects")
        actual_result = self.cursor.fetchall()

        self.assertListEqual(actual_result, expected_result)
        self.assertEqual(procedure_retval, (2,))

    def test_sign_in_two(self):
        expected_result = [(2, "test_obj_name1", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid1),
                           (3, "test_obj_name2", "test_obj_desc", "test_obj_device", {'bar': 'baz'}, self.test_obj_uuid2)]

        param_list = ["test_obj_name1", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid1]
        self.cursor.callproc("api.sign_in", param_list)
        param_list = ["test_obj_name2", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid2]
        self.cursor.callproc("api.sign_in", param_list)
        self.conn.commit()
        procedure_retval = self.cursor.fetchone()

        self.cursor.execute("SELECT * FROM core.sius_objects")
        actual_result = self.cursor.fetchall()

        self.assertListEqual(actual_result, expected_result)
        self.assertEqual(procedure_retval, (3,))

    def test_position_update(self):
        param_list = ["test_obj_name1", "test_obj_desc", "test_obj_device", '{"bar": "baz"}', self.test_obj_uuid1]
        self.cursor.callproc("api.sign_in", param_list)
        param_list = [2, 4.4, 5.45, 73.4]
        self.cursor.callproc("api.update_position", param_list)
        self.conn.commit()

        self.cursor.execute("SELECT * FROM core.sius_positions")
        self.conn.commit()
        actual_result = self.cursor.fetchall()

        self.assertEqual(len(actual_result), 1)
        actual_result = actual_result[0]
        self.assertEqual(actual_result[0], 2)
        self.assertEqual(actual_result[1], 2)
