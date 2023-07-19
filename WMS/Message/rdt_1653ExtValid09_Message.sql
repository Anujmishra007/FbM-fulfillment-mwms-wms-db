--rdt_1653ExtValid09
exec rdt.rdtDropMsg 201251 , 201300

execute rdt.rdtAddMsg 201251, 10, 'ERROR:              ',   'us_english', 1653
execute rdt.rdtAddMsg 201252, 10, 'PALLET IS SPECIALLY ',   'us_english', 1653
execute rdt.rdtAddMsg 201253, 10, 'PALLETIZED BY       ',   'us_english', 1653
execute rdt.rdtAddMsg 201254, 10, 'ERROR:              ',   'us_english', 1653
execute rdt.rdtAddMsg 201255, 10, 'ORDER NEED TO BE    ',   'us_english', 1653
execute rdt.rdtAddMsg 201256, 10, 'PALLETIZED BY       ',   'us_english', 1653
execute rdt.rdtAddMsg 201257, 10, 'CANNOT MIX PALLET   ',   'us_english', 1653
execute rdt.rdtAddMsg 201258, 10, 'SCANNED HEIGHT      ',   'us_english', 1653
execute rdt.rdtAddMsg 201259, 10, 'NOT IN RANGE        ',   'us_english', 1653
execute rdt.rdtAddMsg 201260, 10, 'ORDERS HAS NOT      ',   'us_english', 1653
execute rdt.rdtAddMsg 201261, 10, 'UNDERGONE VAS       ',   'us_english', 1653
execute rdt.rdtAddMsg 201262, 10, 'EXCEED MAX CARTON   ',   'us_english', 1653
execute rdt.rdtAddMsg 201263, 10, 'PER LANE            ',   'us_english', 1653
execute rdt.rdtAddMsg 201264, 10, 'EXCEED MAX CARTON   ',   'us_english', 1653
execute rdt.rdtAddMsg 201265, 10, 'PER PALLET          ',   'us_english', 1653
execute rdt.rdtAddMsg 201266, 10, 'ERROR:              ',   'us_english', 1653
execute rdt.rdtAddMsg 201267, 10, 'PALLETIZED CUSTOMER ',   'us_english', 1653
execute rdt.rdtAddMsg 201268, 10, 'CLOSE OR SCAN TO    ',   'us_english', 1653
execute rdt.rdtAddMsg 201269, 10, 'FIRST               ',   'us_english', 1653
execute rdt.rdtAddMsg 201270, 10, '201270 Lane Mix Wave',   'us_english', 1653
execute rdt.rdtAddMsg 201271, 10, '201271 LaneMixShpper',   'us_english', 1653
execute rdt.rdtAddMsg 201272, 10, 'NOT ALLOW TO MIX    ',   'us_english', 1653
execute rdt.rdtAddMsg 201273, 10, 'PALLETIZED AND      ',   'us_english', 1653
execute rdt.rdtAddMsg 201274, 10, 'NON PALLETIZED      ',   'us_english', 1653
execute rdt.rdtAddMsg 201275, 10, 'CUSTOMER IN LANE    ',   'us_english', 1653
execute rdt.rdtAddMsg 201276, 10, '201276 OrdTypeXMatch',   'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 201251 AND 201300

