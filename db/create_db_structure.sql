--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.2

-- Started on 2017-05-18 23:58:41

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 16 (class 2615 OID 16395)
-- Name: api; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO postgres;

--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA api; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA api IS 'Schema for public methods';


--
-- TOC entry 15 (class 2615 OID 16394)
-- Name: core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA core;


ALTER SCHEMA core OWNER TO postgres;

--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA core; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA core IS 'Schema for private objects - tables etc.';


--
-- TOC entry 13 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET search_path = core, pg_catalog;

--
-- TOC entry 282 (class 1255 OID 16410)
-- Name: object_create(text, text, text, jsonb); Type: FUNCTION; Schema: core; Owner: postgres
--

CREATE FUNCTION object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, OUT o_obj_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO core.sius_objects
    (
        obj_name,
        obj_desc,
        obj_device,
        obj_data
    )
    VALUES
    (
        i_obj_name,
        i_obj_desc,
        i_obj_device,
        i_obj_data
    )
    RETURNING obj_id
    INTO o_obj_id;
    RETURN;
END;
$$;


ALTER FUNCTION core.object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, OUT o_obj_id integer) OWNER TO postgres;

--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 282
-- Name: FUNCTION object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, OUT o_obj_id integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, OUT o_obj_id integer) IS 'Create new object';


--
-- TOC entry 1611 (class 1255 OID 18604)
-- Name: position_create(integer, double precision, double precision); Type: FUNCTION; Schema: core; Owner: postgres
--

CREATE FUNCTION position_create(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    o_status := -1;
    
    INSERT INTO core.sius_positions
    (
        pos_obj_id,
        pos_position
    )
    VALUES
    (
        i_obj_id,
        ST_MakePoint(i_latitude, i_longitude)
    )
    RETURNING pos_id
    INTO o_status;
    RETURN;
END;
$$;


ALTER FUNCTION core.position_create(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) OWNER TO postgres;

--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 1611
-- Name: FUNCTION position_create(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION position_create(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) IS 'Function to create new position';


--
-- TOC entry 1612 (class 1255 OID 18605)
-- Name: position_update(integer, double precision, double precision); Type: FUNCTION; Schema: core; Owner: postgres
--

CREATE FUNCTION position_update(i_pos_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    l_update_count INTEGER;
BEGIN
    o_status := -1;
    UPDATE core.sius_positions
    SET
        pos_position = ST_MakePoint(i_latitude, i_longitude),
        pos_timestamp = now()
    WHERE pos_id = i_pos_id;
    GET DIAGNOSTICS l_update_count = ROW_COUNT;
    IF l_update_count > 0 THEN
        o_status := 1;
    END IF;
    RETURN;
END;$$;


ALTER FUNCTION core.position_update(i_pos_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) OWNER TO postgres;

--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 1612
-- Name: FUNCTION position_update(i_pos_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION position_update(i_pos_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) IS 'Method for updating existing position';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 194 (class 1259 OID 16400)
-- Name: sius_objects; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE sius_objects (
    obj_id integer NOT NULL,
    obj_name text NOT NULL,
    obj_desc text,
    obj_device text,
    obj_data jsonb
);


ALTER TABLE sius_objects OWNER TO postgres;

--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE sius_objects; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON TABLE sius_objects IS 'Table with object definitions';


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sius_objects.obj_id; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_id IS 'Object ID';


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sius_objects.obj_name; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_name IS 'Object name';


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sius_objects.obj_desc; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_desc IS 'Object description';


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sius_objects.obj_device; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_device IS 'Object connection device identifier';


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sius_objects.obj_data; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_data IS 'Object data dictionary';


--
-- TOC entry 193 (class 1259 OID 16398)
-- Name: sius_objects_obj_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE sius_objects_obj_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sius_objects_obj_id_seq OWNER TO postgres;

--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 193
-- Name: sius_objects_obj_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE sius_objects_obj_id_seq OWNED BY sius_objects.obj_id;


--
-- TOC entry 274 (class 1259 OID 18587)
-- Name: sius_positions; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE sius_positions (
    pos_id integer NOT NULL,
    pos_obj_id integer NOT NULL,
    pos_timestamp timestamp with time zone DEFAULT now() NOT NULL,
    pos_position public.geography NOT NULL
);


ALTER TABLE sius_positions OWNER TO postgres;

--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE sius_positions; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON TABLE sius_positions IS 'Table with objects positions';


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN sius_positions.pos_id; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_id IS 'Position identifier';


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN sius_positions.pos_obj_id; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_obj_id IS 'Object identifier - relation to sius_objects';


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN sius_positions.pos_timestamp; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_timestamp IS 'Date of row insertion';


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN sius_positions.pos_position; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_position IS 'Position coordinates';


--
-- TOC entry 273 (class 1259 OID 18585)
-- Name: sius_positions_pos_id_seq; Type: SEQUENCE; Schema: core; Owner: postgres
--

CREATE SEQUENCE sius_positions_pos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sius_positions_pos_id_seq OWNER TO postgres;

--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 273
-- Name: sius_positions_pos_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE sius_positions_pos_id_seq OWNED BY sius_positions.pos_id;


--
-- TOC entry 3753 (class 2604 OID 16403)
-- Name: obj_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_objects ALTER COLUMN obj_id SET DEFAULT nextval('sius_objects_obj_id_seq'::regclass);


--
-- TOC entry 3754 (class 2604 OID 18590)
-- Name: pos_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_positions ALTER COLUMN pos_id SET DEFAULT nextval('sius_positions_pos_id_seq'::regclass);


--
-- TOC entry 3758 (class 2606 OID 16408)
-- Name: obj_pk; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_objects
    ADD CONSTRAINT obj_pk PRIMARY KEY (obj_id);


--
-- TOC entry 3761 (class 2606 OID 18596)
-- Name: pos_id_pk; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_positions
    ADD CONSTRAINT pos_id_pk PRIMARY KEY (pos_id);


--
-- TOC entry 3759 (class 1259 OID 18602)
-- Name: fki_pos_obj_id_fk; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fki_pos_obj_id_fk ON sius_positions USING btree (pos_obj_id);


--
-- TOC entry 3756 (class 1259 OID 16409)
-- Name: obj_id_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE UNIQUE INDEX obj_id_idx ON sius_objects USING btree (obj_id);


--
-- TOC entry 3762 (class 2606 OID 18597)
-- Name: pos_obj_id_fk; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_positions
    ADD CONSTRAINT pos_obj_id_fk FOREIGN KEY (pos_obj_id) REFERENCES sius_objects(obj_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 13
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2017-05-18 23:58:41

--
-- PostgreSQL database dump complete
--

