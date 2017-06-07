--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.2

-- Started on 2017-06-05 23:15:40

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 17 (class 2615 OID 16395)
-- Name: api; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO postgres;

--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 17
-- Name: SCHEMA api; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA api IS 'Schema for public methods';


--
-- TOC entry 16 (class 2615 OID 16394)
-- Name: core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA core;


ALTER SCHEMA core OWNER TO postgres;

--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA core; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA core IS 'Schema for private objects - tables etc.';


SET search_path = api, pg_catalog;

--
-- TOC entry 1631 (class 1255 OID 18647)
-- Name: get_positions_simple(integer); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION get_positions_simple(i_obj_id integer) RETURNS TABLE(o_pos_id integer, o_latitude double precision, o_longitude double precision)
    LANGUAGE plpgsql
    AS $$
DECLARE
  l_pos_id integer;
  l_status integer;
  l_radius DOUBLE PRECISION;
BEGIN
  l_radius := 50000.0;
  l_pos_id := -1;
  -- Get existing position by object ID
  SELECT core.position_get_by_obj_id(
      i_obj_id := i_obj_id
  ) INTO l_pos_id;
  IF l_pos_id IS NULL OR l_pos_id < 0 THEN
    -- Something went wrong
    RETURN;
  END IF;
  -- Return positions in radius
  RETURN QUERY
  SELECT pos_obj_id, ST_X(pos_position::geometry), ST_Y(pos_position::geometry)
  FROM core.position_get_in_radius(
      i_pos_id := l_pos_id,
      i_radius := l_radius
  );
END;$$;


ALTER FUNCTION api.get_positions_simple(i_obj_id integer) OWNER TO postgres;

--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 1631
-- Name: FUNCTION get_positions_simple(i_obj_id integer); Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON FUNCTION get_positions_simple(i_obj_id integer) IS 'Get positions in 10 km';


--
-- TOC entry 1614 (class 1255 OID 18630)
-- Name: sign_in(text, text, text, jsonb, uuid); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION sign_in(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    SELECT core.get_object_id_by_access_key(
        i_obj_access_key := i_obj_access_key
    ) INTO o_obj_id;

    IF o_obj_id IS NULL OR o_obj_id < 0 THEN
        SELECT core.object_create(
            i_obj_name := i_obj_name,
            i_obj_desc := i_obj_desc,
            i_obj_device := i_obj_device,
            i_obj_data := i_obj_data,
            i_obj_access_key := i_obj_access_key
        ) INTO o_obj_id;
        IF o_obj_id IS NULL OR o_obj_id < 0 THEN
            o_obj_id := -1;
        END IF;
    END IF;
    
    RETURN;
END;
$$;


ALTER FUNCTION api.sign_in(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer) OWNER TO postgres;

--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 1614
-- Name: FUNCTION sign_in(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer); Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON FUNCTION sign_in(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer) IS 'Obtain object ID either by getting existing object ID by access key or creating new one';


--
-- TOC entry 1628 (class 1255 OID 18645)
-- Name: sign_in_simple(); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION sign_in_simple(OUT o_obj_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT core.object_create(
      i_obj_name := '',
      i_obj_desc := NULL,
      i_obj_device := NULL,
      i_obj_data := NULL,
      i_obj_access_key := uuid_generate_v4()
  ) INTO o_obj_id;
  IF o_obj_id IS NULL OR o_obj_id < 0 THEN
    o_obj_id := -1;
  END IF;

  RETURN;
END;
$$;


ALTER FUNCTION api.sign_in_simple(OUT o_obj_id integer) OWNER TO postgres;

--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 1628
-- Name: FUNCTION sign_in_simple(OUT o_obj_id integer); Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON FUNCTION sign_in_simple(OUT o_obj_id integer) IS 'Obtain new object ID';


--
-- TOC entry 1627 (class 1255 OID 18644)
-- Name: update_position(integer, double precision, double precision, double precision); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION update_position(i_obj_id integer, i_latitude double precision, i_longitude double precision, i_radius double precision) RETURNS TABLE(o_pos_id integer, o_latitude double precision, o_longitude double precision)
    LANGUAGE plpgsql
    AS $$
DECLARE
    l_pos_id integer;
    l_status integer;
BEGIN
    l_pos_id := -1;
    -- Get existing position by object ID
    SELECT core.position_get_by_obj_id(
        i_obj_id := i_obj_id
    ) INTO l_pos_id;
    IF l_pos_id IS NULL OR l_pos_id < 0 THEN
        -- If does not exist -> create new one
        SELECT core.position_create(
            i_obj_id := i_obj_id,
            i_latitude := i_latitude,
            i_longitude := i_longitude
        ) INTO l_pos_id;
        IF l_pos_id IS NULL OR l_pos_id < 0 THEN
            -- Something went wrong
            RETURN;
        END IF;
    ELSE
        l_status := -1;
        -- Update object position
        SELECT core.position_update(
            i_pos_id := l_pos_id,
            i_latitude := i_latitude,
            i_longitude := i_longitude
        ) INTO l_status;
        IF l_status IS NULL OR l_status < 0 THEN
            -- Something went wrong
            RETURN;
        END IF;
    END IF;
    -- Return positions in radius
    RETURN QUERY
    SELECT pos_id, ST_X(pos_position::geometry), ST_Y(pos_position::geometry)
    FROM core.position_get_in_radius(
        i_pos_id := l_pos_id,
        i_radius := i_radius
    );
END;$$;


ALTER FUNCTION api.update_position(i_obj_id integer, i_latitude double precision, i_longitude double precision, i_radius double precision) OWNER TO postgres;

--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 1627
-- Name: FUNCTION update_position(i_obj_id integer, i_latitude double precision, i_longitude double precision, i_radius double precision); Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON FUNCTION update_position(i_obj_id integer, i_latitude double precision, i_longitude double precision, i_radius double precision) IS 'Update object position and get positions in given radius';


--
-- TOC entry 1629 (class 1255 OID 18646)
-- Name: update_position_simple(integer, double precision, double precision); Type: FUNCTION; Schema: api; Owner: postgres
--

CREATE FUNCTION update_position_simple(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  l_pos_id integer;
BEGIN
  l_pos_id := -1;
  -- Get existing position by object ID
  SELECT core.position_get_by_obj_id(
      i_obj_id := i_obj_id
  ) INTO l_pos_id;
  IF l_pos_id IS NULL OR l_pos_id < 0 THEN
    -- If does not exist -> create new one
    SELECT core.position_create(
        i_obj_id := i_obj_id,
        i_latitude := i_latitude,
        i_longitude := i_longitude
    ) INTO o_status;
    IF o_status IS NULL OR o_status < 0 THEN
      -- Something went wrong
      RETURN;
    END IF;
  ELSE
    o_status := -1;
    -- Update object position
    SELECT core.position_update(
        i_pos_id := l_pos_id,
        i_latitude := i_latitude,
        i_longitude := i_longitude
    ) INTO o_status;
    IF o_status IS NULL OR o_status < 0 THEN
      -- Something went wrong
      RETURN;
    END IF;
  END IF;
  RETURN;
END;$$;


ALTER FUNCTION api.update_position_simple(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) OWNER TO postgres;

--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 1629
-- Name: FUNCTION update_position_simple(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer); Type: COMMENT; Schema: api; Owner: postgres
--

COMMENT ON FUNCTION update_position_simple(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) IS 'Update object position';


SET search_path = core, pg_catalog;

--
-- TOC entry 1613 (class 1255 OID 18629)
-- Name: get_object_id_by_access_key(uuid); Type: FUNCTION; Schema: core; Owner: postgres
--

CREATE FUNCTION get_object_id_by_access_key(i_obj_access_key uuid, OUT o_obj_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    SELECT obj_id
    INTO o_obj_id
    FROM core.sius_objects
    WHERE obj_access_key = i_obj_access_key;
    RETURN;
END;
$$;


ALTER FUNCTION core.get_object_id_by_access_key(i_obj_access_key uuid, OUT o_obj_id integer) OWNER TO postgres;

--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 1613
-- Name: FUNCTION get_object_id_by_access_key(i_obj_access_key uuid, OUT o_obj_id integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION get_object_id_by_access_key(i_obj_access_key uuid, OUT o_obj_id integer) IS 'Using unique access key get object id';


--
-- TOC entry 1616 (class 1255 OID 18628)
-- Name: object_create(text, text, text, jsonb, uuid); Type: FUNCTION; Schema: core; Owner: postgres
--

CREATE FUNCTION object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO core.sius_objects
    (
        obj_name,
        obj_desc,
        obj_device,
        obj_data,
        obj_access_key
    )
    VALUES
    (
        i_obj_name,
        i_obj_desc,
        i_obj_device,
        i_obj_data,
        i_obj_access_key
    )
    RETURNING obj_id
    INTO o_obj_id;
    RETURN;
END;
$$;


ALTER FUNCTION core.object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer) OWNER TO postgres;

--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 1616
-- Name: FUNCTION object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION object_create(i_obj_name text, i_obj_desc text, i_obj_device text, i_obj_data jsonb, i_obj_access_key uuid, OUT o_obj_id integer) IS 'Create new object';


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
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 1611
-- Name: FUNCTION position_create(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION position_create(i_obj_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) IS 'Function to create new position';


--
-- TOC entry 1615 (class 1255 OID 18631)
-- Name: position_get_by_obj_id(integer); Type: FUNCTION; Schema: core; Owner: postgres
--

CREATE FUNCTION position_get_by_obj_id(i_obj_id integer, OUT o_pos_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    o_pos_id := -1;
    SELECT pos_id
    INTO o_pos_id
    FROM core.sius_positions
    WHERE pos_obj_id = i_obj_id;
    RETURN;
END;
$$;


ALTER FUNCTION core.position_get_by_obj_id(i_obj_id integer, OUT o_pos_id integer) OWNER TO postgres;

--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 1615
-- Name: FUNCTION position_get_by_obj_id(i_obj_id integer, OUT o_pos_id integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION position_get_by_obj_id(i_obj_id integer, OUT o_pos_id integer) IS 'Get position ID by associated object ID';


--
-- TOC entry 1630 (class 1255 OID 18648)
-- Name: position_get_in_radius(integer, double precision); Type: FUNCTION; Schema: core; Owner: postgres
--

CREATE FUNCTION position_get_in_radius(i_pos_id integer, i_radius double precision) RETURNS TABLE(pos_obj_id integer, pos_position public.geography)
    LANGUAGE plpgsql
    AS $$
DECLARE
  l_position GEOGRAPHY;
BEGIN
  SELECT
    pos.pos_position
  INTO
    l_position
  FROM core.sius_positions pos
  WHERE pos.pos_id = i_pos_id;

  RETURN QUERY
  SELECT
    pos.pos_obj_id,
    pos.pos_position
  FROM core.sius_positions pos
  WHERE pos.pos_id <> i_pos_id AND
        ST_DWithin(pos.pos_position, l_position, i_radius);
END;
$$;


ALTER FUNCTION core.position_get_in_radius(i_pos_id integer, i_radius double precision) OWNER TO postgres;

--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 1630
-- Name: FUNCTION position_get_in_radius(i_pos_id integer, i_radius double precision); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION position_get_in_radius(i_pos_id integer, i_radius double precision) IS 'Get positions in radius';


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
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 1612
-- Name: FUNCTION position_update(i_pos_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer); Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON FUNCTION position_update(i_pos_id integer, i_latitude double precision, i_longitude double precision, OUT o_status integer) IS 'Method for updating existing position';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 195 (class 1259 OID 16400)
-- Name: sius_objects; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE sius_objects (
    obj_id integer NOT NULL,
    obj_name text NOT NULL,
    obj_desc text,
    obj_device text,
    obj_data jsonb,
    obj_access_key uuid NOT NULL
);


ALTER TABLE sius_objects OWNER TO postgres;

--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE sius_objects; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON TABLE sius_objects IS 'Table with object definitions';


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN sius_objects.obj_id; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_id IS 'Object ID';


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN sius_objects.obj_name; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_name IS 'Object name';


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN sius_objects.obj_desc; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_desc IS 'Object description';


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN sius_objects.obj_device; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_device IS 'Object connection device identifier';


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN sius_objects.obj_data; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_data IS 'Object data dictionary';


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN sius_objects.obj_access_key; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_objects.obj_access_key IS 'Object unique access key';


--
-- TOC entry 194 (class 1259 OID 16398)
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
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 194
-- Name: sius_objects_obj_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE sius_objects_obj_id_seq OWNED BY sius_objects.obj_id;


--
-- TOC entry 275 (class 1259 OID 18587)
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
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE sius_positions; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON TABLE sius_positions IS 'Table with objects positions';


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN sius_positions.pos_id; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_id IS 'Position identifier';


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN sius_positions.pos_obj_id; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_obj_id IS 'Object identifier - relation to sius_objects';


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN sius_positions.pos_timestamp; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_timestamp IS 'Date of row insertion';


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN sius_positions.pos_position; Type: COMMENT; Schema: core; Owner: postgres
--

COMMENT ON COLUMN sius_positions.pos_position IS 'Position coordinates';


--
-- TOC entry 274 (class 1259 OID 18585)
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
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 274
-- Name: sius_positions_pos_id_seq; Type: SEQUENCE OWNED BY; Schema: core; Owner: postgres
--

ALTER SEQUENCE sius_positions_pos_id_seq OWNED BY sius_positions.pos_id;


--
-- TOC entry 3740 (class 2604 OID 16403)
-- Name: obj_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_objects ALTER COLUMN obj_id SET DEFAULT nextval('sius_objects_obj_id_seq'::regclass);


--
-- TOC entry 3741 (class 2604 OID 18590)
-- Name: pos_id; Type: DEFAULT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_positions ALTER COLUMN pos_id SET DEFAULT nextval('sius_positions_pos_id_seq'::regclass);


--
-- TOC entry 3746 (class 2606 OID 16408)
-- Name: obj_pk; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_objects
    ADD CONSTRAINT obj_pk PRIMARY KEY (obj_id);


--
-- TOC entry 3749 (class 2606 OID 18596)
-- Name: pos_id_pk; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_positions
    ADD CONSTRAINT pos_id_pk PRIMARY KEY (pos_id);


--
-- TOC entry 3747 (class 1259 OID 18606)
-- Name: fki_pos_obj_id_fk; Type: INDEX; Schema: core; Owner: postgres
--

CREATE UNIQUE INDEX fki_pos_obj_id_fk ON sius_positions USING btree (pos_obj_id);


--
-- TOC entry 3743 (class 1259 OID 18626)
-- Name: obj_access_key_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE UNIQUE INDEX obj_access_key_idx ON sius_objects USING btree (obj_access_key);


--
-- TOC entry 3744 (class 1259 OID 16409)
-- Name: obj_id_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE UNIQUE INDEX obj_id_idx ON sius_objects USING btree (obj_id);


--
-- TOC entry 3750 (class 1259 OID 18608)
-- Name: pos_position_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX pos_position_idx ON sius_positions USING gist (pos_position);


--
-- TOC entry 3751 (class 2606 OID 18597)
-- Name: pos_obj_id_fk; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY sius_positions
    ADD CONSTRAINT pos_obj_id_fk FOREIGN KEY (pos_obj_id) REFERENCES sius_objects(obj_id) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2017-06-05 23:15:40

--
-- PostgreSQL database dump complete
--

