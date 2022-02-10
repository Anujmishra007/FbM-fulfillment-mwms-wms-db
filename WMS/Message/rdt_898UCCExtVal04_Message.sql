--rdt_898UCCExtVal04
execute rdt.rdtDropMsg 162401 , 162450

execute rdt.rdtAddMsg 162401, 10, '62401^UPD Log Fail',     'us_english', 898
execute rdt.rdtAddMsg 162402, 10, '62402^UPD SKU Fail',     'us_english', 898
execute rdt.rdtAddMsg 162403, 10, '62403^Need CubicScan',   'us_english', 898

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 162401 AND 162450

