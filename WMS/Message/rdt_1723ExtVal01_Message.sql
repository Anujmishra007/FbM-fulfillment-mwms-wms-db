--rdt_1723ExtVal01
exec rdt.rdtDropMsg 115201 , 115250

execute rdt.rdtAddMsg 115201, 10, '15201^PALLET ALREADY',   'us_english', 1723
execute rdt.rdtAddMsg 115202, 10, '15202^SCANNED TO',       'us_english', 1723
execute rdt.rdtAddMsg 115203, 10, '15203^CONTAINER',        'us_english', 1723

-- (james01)
execute rdt.rdtAddMsg 115204, 10, '15204^LOT FROM',         'us_english', 1723
execute rdt.rdtAddMsg 115205, 10, 'DIFFERENT PLANT',        'us_english', 1723
execute rdt.rdtAddMsg 115206, 10, 'FOUND. CANNOT CONSO.',   'us_english', 1723
execute rdt.rdtAddMsg 115207, 10, '15207^LOT FROM',         'us_english', 1723
execute rdt.rdtAddMsg 115208, 10, 'DIFFERENT PLANT',        'us_english', 1723
execute rdt.rdtAddMsg 115209, 10, 'FOUND. CANNOT CONSO.',   'us_english', 1723

-- WMS5526 (james03)
execute rdt.rdtAddMsg 115210, 10, 'MIX BATCH NOT ALLOW',    'us_english', 1723

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 115201 AND 115250
