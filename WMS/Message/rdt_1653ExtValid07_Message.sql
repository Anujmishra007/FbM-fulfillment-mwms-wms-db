--rdt_1653ExtValid07
exec rdt.rdtDropMsg 191401 , 191450

execute rdt.rdtAddMsg 191401, 10, 'ERROR:              ',   'us_english', 1653
execute rdt.rdtAddMsg 191402, 10, 'PALLET IS SPECIALLY ',   'us_english', 1653
execute rdt.rdtAddMsg 191403, 10, 'PALLETIZED BY       ',   'us_english', 1653
execute rdt.rdtAddMsg 191404, 10, 'ERROR:              ',   'us_english', 1653
execute rdt.rdtAddMsg 191405, 10, 'ORDER NEED TO BE    ',   'us_english', 1653
execute rdt.rdtAddMsg 191406, 10, 'PALLETIZED BY       ',   'us_english', 1653
execute rdt.rdtAddMsg 191407, 10, 'CANNOT MIX PALLET   ',   'us_english', 1653
execute rdt.rdtAddMsg 191408, 10, 'SCANNED HEIGHT      ',   'us_english', 1653
execute rdt.rdtAddMsg 191409, 10, 'NOT IN RANGE        ',   'us_english', 1653
execute rdt.rdtAddMsg 191410, 10, 'ORDERS HAS NOT      ',   'us_english', 1653
execute rdt.rdtAddMsg 191411, 10, 'UNDERGONE VAS       ',   'us_english', 1653
execute rdt.rdtAddMsg 191412, 10, 'EXCEED MAX CARTON   ',   'us_english', 1653
execute rdt.rdtAddMsg 191413, 10, 'PER LANE            ',   'us_english', 1653
execute rdt.rdtAddMsg 191414, 10, 'EXCEED MAX CARTON   ',   'us_english', 1653
execute rdt.rdtAddMsg 191415, 10, 'PER PALLET          ',   'us_english', 1653
execute rdt.rdtAddMsg 191416, 10, 'ERROR:              ',   'us_english', 1653
execute rdt.rdtAddMsg 191417, 10, 'PALLETIZED CUSTOMER ',   'us_english', 1653
execute rdt.rdtAddMsg 191418, 10, 'CLOSE OR SCAN TO    ',   'us_english', 1653
execute rdt.rdtAddMsg 191419, 10, 'FIRST               ',   'us_english', 1653
execute rdt.rdtAddMsg 191420, 10, '191420 Lane Mix Wave',   'us_english', 1653
execute rdt.rdtAddMsg 191421, 10, '191421 LaneMixShpper',   'us_english', 1653
execute rdt.rdtAddMsg 191422, 10, 'NOT ALLOW TO MIX    ',   'us_english', 1653
execute rdt.rdtAddMsg 191423, 10, 'PALLETIZED AND      ',   'us_english', 1653
execute rdt.rdtAddMsg 191424, 10, 'NON PALLETIZED      ',   'us_english', 1653
execute rdt.rdtAddMsg 191425, 10, 'CUSTOMER IN LANE    ',   'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191401 AND 191450

