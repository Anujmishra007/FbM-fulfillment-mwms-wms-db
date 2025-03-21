--rdt_1641ExtValidSP21
exec rdt.rdtDropMsg 229951 , 230000

execute rdt.rdtAddMsg 229951, 10, '229951LocNotStage', 'us_english', 1641, 0, '229951 Location type is not a Staging'
execute rdt.rdtAddMsg 229952, 10, '229952WaveNotMatch', 'us_english', 1641, 0, '229952 WaveKey does not match'
