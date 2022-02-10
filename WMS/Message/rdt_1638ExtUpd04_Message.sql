--rdt_1638ExtUpd04
execute rdt.rdtDropMsg 162301 , 162350

execute rdt.rdtAddMsg 162301, 10, '62301^No OrderKey',      'us_english', 1638
execute rdt.rdtAddMsg 162302, 10, '62302^NO ORDERKEY',      'us_english', 1638
execute rdt.rdtAddMsg 162303, 10, '62303^INS MBOL Fail',    'us_english', 1638
execute rdt.rdtAddMsg 162304, 10, '62304^MBOL shipped',     'us_english', 1638
execute rdt.rdtAddMsg 162305, 10, '62305^MBOL FAC Diff',    'us_english', 1638
execute rdt.rdtAddMsg 162306, 10, '62306^INS MBDtl Fail',   'us_english', 1638
execute rdt.rdtAddMsg 162307, 10, '62307^UPD MBDtl Fail',   'us_english', 1638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 162301 AND 162350

