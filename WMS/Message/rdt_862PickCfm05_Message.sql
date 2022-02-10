-- rdt_862PickCfm05
exec rdt.rdtDropMsg 138551 , 138600

execute rdt.rdtAddMsg 138551, 10, '38551^Bad TaskQTY',      'us_english', 862
execute rdt.rdtAddMsg 138552, 10, '38552^Over pick',        'us_english', 862
execute rdt.rdtAddMsg 138553, 10, '38553^Get PKDtl fail',   'us_english', 862
execute rdt.rdtAddMsg 138554, 10, '38554^Task changed',     'us_english', 862
execute rdt.rdtAddMsg 138555, 10, '38555^Task changed',     'us_english', 862
execute rdt.rdtAddMsg 138556, 10, '38556^Offset Error',     'us_english', 862
execute rdt.rdtAddMsg 138557, 10, '38557^Upd PKDtl fail',   'us_english', 862
execute rdt.rdtAddMsg 138558, 10, '38558^Task changed',     'us_english', 862
execute rdt.rdtAddMsg 138559, 10, '38559^Scan Out Fail',    'us_english', 862
execute rdt.rdtAddMsg 138560, 10, '38560^InsPackHdrFail',   'us_english', 862
execute rdt.rdtAddMsg 138561, 10, '38561^InsPackDtlFail',   'us_english', 862
execute rdt.rdtAddMsg 138562, 10, '38562^InsPackDtlFail',   'us_english', 862
execute rdt.rdtAddMsg 138563, 10, '38563^UpdPackDtlFail',   'us_english', 862
execute rdt.rdtAddMsg 138564, 10, '38564^PackInfo Fail',    'us_english', 862

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 138551 AND 138600

