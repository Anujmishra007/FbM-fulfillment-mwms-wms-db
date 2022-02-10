--rdt_644ExtValid01
execute rdt.rdtDropMsg 150101, 150150

execute rdt.rdtAddMsg 150101, 10, '50101^POS NOT ENUF',   'us_english', 644
execute rdt.rdtAddMsg 150102, 10, '50102^CANNOT MIX SKU', 'us_english', 644
execute rdt.rdtAddMsg 150103, 10, '50103^NO LOCATION',    'us_english', 644

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 150101 AND 150150