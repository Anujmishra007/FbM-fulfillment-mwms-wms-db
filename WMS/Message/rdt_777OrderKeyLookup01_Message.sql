--rdt_777OrderKeyLookup01
--FCR-9200
exec rdt.rdtDropMsg 251501, 251550

execute rdt.rdtAddMsg 251501, 10, '251501Invalid Order ', 'us_english', 777, 0, '251501 Invalid OrderKey'
execute rdt.rdtAddMsg 251502, 10, '251502InsPHdrFail   ', 'us_english', 777, 0, '251502 Insert PickHeader Fail'
execute rdt.rdtAddMsg 251503, 10, '251503InsPHdrFail   ', 'us_english', 777, 0, '251503 Insert PackHeader Fail'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 251501 AND 251550