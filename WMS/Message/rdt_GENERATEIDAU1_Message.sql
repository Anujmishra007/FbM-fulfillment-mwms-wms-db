-- 269351 - 269400

exec rdt.rdtDropMsg 269351, 269400

-- Function 1812 Messages
execute rdt.rdtAddMsg 269351 ,10, '269351^No GenIDType'                 , 'us_english', 1812, 0,'269351 No GenIDType Configuration'
execute rdt.rdtAddMsg 269352 ,10, '269352^NoCodelistConfiguration'      , 'us_english', 1812, 0,'269352 No Codelist Configuration'
execute rdt.rdtAddMsg 269353 ,10, '269353^Code2 Error'                  , 'us_english', 1812, 0,'269353 Code2 (Length of Sequence) Error'
execute rdt.rdtAddMsg 269354 ,10, '269354^UDF03/UDF04 Error'            , 'us_english', 1812, 0,'269354 UDF03 (Min Sequence)/UDF04(Max Sequence) Error'
execute rdt.rdtAddMsg 269355 ,10, '269355^ResetNCounterFailed'          , 'us_english', 1812, 0,'269355 Reset NCounter Failed'
execute rdt.rdtAddMsg 269356 ,10, '269356^Getkey Error'                 , 'us_english', 1812, 0,'269356 Getkey Error'
execute rdt.rdtAddMsg 269357 ,10, '269357^Reset NCounter Failed'        , 'us_english', 1812, 0,'269357 Reset NCounter Failed'
execute rdt.rdtAddMsg 269358 ,10, '269358^Reset NCounter Failed'        , 'us_english', 1812, 0,'269358 Reset NCounter Failed'

-- Function 1770 Messages (same messages, different function)
execute rdt.rdtAddMsg 269351 ,10, '269351^No GenIDType'                 , 'us_english', 1770, 0,'269351 No GenIDType Configuration'
execute rdt.rdtAddMsg 269352 ,10, '269352^NoCodelistConfiguration'      , 'us_english', 1770, 0,'269352 No Codelist Configuration'
execute rdt.rdtAddMsg 269353 ,10, '269353^Code2 Error'                  , 'us_english', 1770, 0,'269353 Code2 (Length of Sequence) Error'
execute rdt.rdtAddMsg 269354 ,10, '269354^UDF03/UDF04 Error'            , 'us_english', 1770, 0,'269354 UDF03 (Min Sequence)/UDF04(Max Sequence) Error'
execute rdt.rdtAddMsg 269355 ,10, '269355^ResetNCounterFailed'          , 'us_english', 1770, 0,'269355 Reset NCounter Failed'
execute rdt.rdtAddMsg 269356 ,10, '269356^Getkey Error'                 , 'us_english', 1770, 0,'269356 Getkey Error'
execute rdt.rdtAddMsg 269357 ,10, '269357^Reset NCounter Failed'        , 'us_english', 1770, 0,'269357 Reset NCounter Failed'
execute rdt.rdtAddMsg 269358 ,10, '269358^Reset NCounter Failed'        , 'us_english', 1770, 0,'269358 Reset NCounter Failed'

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 269351 AND 269400
