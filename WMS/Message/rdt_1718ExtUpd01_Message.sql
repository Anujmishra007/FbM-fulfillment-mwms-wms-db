--rdt_1718ExtUpd01
--FCR-12388
exec rdt.rdtDropMsg 266001, 266050

execute rdt.rdtAddMsg 266001, 10, '266001^CloMBolFail',   'us_english', 1718, 0, '266001 Close MBOL failed'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 266001 AND 266050