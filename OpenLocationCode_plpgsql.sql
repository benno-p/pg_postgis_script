--A function to get a pluscode from lat/lng point
--specify a code_length 2,4,6,8,10 or + as a third parameter

CREATE OR REPLACE FUNCTION pluscode(
    _lat double precision,
    _lng double precision,
    _codelength integer)
  RETURNS text AS
$BODY$
DECLARE
code text DEFAULT '';
code_alphabet text := '23456789CFGHJMPQRVWX';
sum_lat_tosubstract float;
sum_lng_tosubstract float;
classic_code int := 10;
precision_up int := 0;
digit_sub FLOAT ARRAY  DEFAULT  ARRAY[20.0, 1.0, 0.05, 0.0025, 0.000125]; 
code_11_digit text default '';
latPlaceValue float;
lngPlaceValue float;
latitude float;
longitude float;
adjust_lat float;
adjust_lng float;
_row float;
_col float;
nb_rows int default 5;
nb_cols int default 4;
_isvalid_params boolean default false;

BEGIN
IF (_codelength < 2 OR (_codelength < 10 AND (_codelength % 2 = 1))) THEN
    RAISE EXCEPTION 'OLCode is not valid --> %', _codelength
    USING HINT = 'Use an int in this array [2,4,6,8,10,10+]';
END IF;
IF (_lat>90) OR (_lat<-90) THEN
    RAISE EXCEPTION 'Latitude limit excedeed  --> %', _lat
    USING HINT = 'Use a value between -90 and 90';
END IF;
IF (_lng>180) OR (_lng<-180) THEN
    RAISE EXCEPTION 'Longitude limit excedeed  --> %', _lng
    USING HINT = 'Use a value between -180 and 180';
END IF;

precision_up := _codelength - classic_code;

--block1 for 2 digits
code = code || substring(code_alphabet from floor((_lat+90)/digit_sub[1])::int + 1 for 1);
sum_lat_tosubstract := (floor((_lat+90)/digit_sub[1])::int ) * digit_sub[1];
code = code || substring(code_alphabet from floor((_lng+180)/digit_sub[1])::int + 1  for 1);
sum_lng_tosubstract := (floor((_lng+180)/digit_sub[1])::int) * digit_sub[1];

--block2 for 4 digits
IF (_codelength > 3) THEN
code = code || substring(code_alphabet from floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[2])::int + 1 for 1);
sum_lat_tosubstract = sum_lat_tosubstract + (floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[2])) * digit_sub[2];
code = code || substring(code_alphabet from floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[2])::int + 1 for 1);
sum_lng_tosubstract = sum_lng_tosubstract + (floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[2])) * digit_sub[2];
ELSE code = code||'00';
END IF;

--block3 for 6 digits
IF (_codelength > 5) THEN
code = code || substring(code_alphabet from floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[3])::int + 1 for 1);
sum_lat_tosubstract = sum_lat_tosubstract + (floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[3])) * digit_sub[3];
code = code || substring(code_alphabet from floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[3])::int + 1 for 1);
sum_lng_tosubstract = sum_lng_tosubstract + (floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[3])) * digit_sub[3];
ELSE code = code||'00';
END IF;

--block4 for 8 digits
IF (_codelength > 7) THEN
code = code || substring(code_alphabet from floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[4])::int + 1 for 1);
sum_lat_tosubstract = sum_lat_tosubstract + (floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[4])) * digit_sub[4];
code = code || substring(code_alphabet from floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[4])::int + 1 for 1);
sum_lng_tosubstract = sum_lng_tosubstract + (floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[4])) * digit_sub[4];
ELSE code = code||'00';
END IF;

code=code||'+';
--block5  for 10 digits
IF (_codelength > 9) THEN
code = code || substring(code_alphabet from floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[5])::int + 1 for 1);
sum_lat_tosubstract = sum_lat_tosubstract + (floor(((_lat+90)-sum_lat_tosubstract)/digit_sub[5])) * digit_sub[5];
code = code || substring(code_alphabet from floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[5])::int + 1 for 1);
sum_lng_tosubstract = sum_lng_tosubstract + (floor(((_lng+180)-sum_lng_tosubstract)/digit_sub[5])) * digit_sub[5];
ELSE code = code||'00';
END IF;

--after 10 digits
IF precision_up > 0 THEN
    code_11_digit = '';
    latPlaceValue := 0.000125;
    lngPlaceValue := 0.000125;
    --delete degrees for lat and lng
    latitude := _lat::numeric % 1.0::numeric;
    longitude := _lng::numeric % 1.0::numeric;
    adjust_lat := latitude::numeric % latPlaceValue::numeric;
    adjust_lng := longitude::numeric % lngPlaceValue::numeric;
    --loop for precision > 10
    --use a grid 5*4
    FOR it IN 1..precision_up LOOP
        _row = floor(adjust_lat / ( latPlaceValue / nb_rows));
        _col = floor(adjust_lng / ( lngPlaceValue / nb_cols));
        latPlaceValue = latPlaceValue / nb_rows;
        lngPlaceValue = lngPlaceValue / nb_cols;
        adjust_lat = adjust_lat - (_row * latPlaceValue);
        adjust_lng = adjust_lng - (_col * lngPlaceValue);
        code_11_digit = code_11_digit || substring(code_alphabet from ((_row * nb_cols + _col))::int + 1 for 1);
    END LOOP;
END IF;

RETURN code||code_11_digit ;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;