-- Function: public.update_json(json, text, text)

-- DROP FUNCTION public.update_json(json, text, text);

CREATE OR REPLACE FUNCTION public.update_json(
    json_in json,
    key_name text,
    key_value text)
  RETURNS json AS
$BODY$
	DECLARE item json;
	DECLARE fields hstore;
BEGIN
  -- Initialize the hstore with desired key value
  fields := hstore(key_name,key_value);

  -- Parse through Input Json and push each key into hstore 
  FOR item IN  SELECT row_to_json(r.*) FROM json_each_text(json_in) AS r
  LOOP
    -- RAISE NOTICE 'Parsing Item % %', item->>'key', item->>'value';
	IF ( LOWER(item->>'key') like key_name ) THEN
		fields := (fields::hstore || hstore(item->>'key', key_value));
	ELSE
		fields := (fields::hstore || hstore(item->>'key', item->>'value'));
	END IF;
    --RAISE NOTICE 'Fields %', fields::TEXT;
  END LOOP;
  -- RAISE NOTICE 'Result %', hstore_to_json(fields);
  RETURN hstore_to_json(fields);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;