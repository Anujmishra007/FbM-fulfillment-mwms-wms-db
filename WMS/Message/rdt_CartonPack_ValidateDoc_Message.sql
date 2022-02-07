--rdt_CartonPack_ValidateDoc
rdt.rdtDropMsg 141851 , 141900

execute rdt.rdtAddMsg 141851, 10, '41851^BAD WAVEKEY',      'us_english', 834
execute rdt.rdtAddMsg 141852, 10, '41852^NOTHING 2 PACK',   'us_english', 834
execute rdt.rdtAddMsg 141853, 10, '41853^BAD LOADKEY',      'us_english', 834
execute rdt.rdtAddMsg 141854, 10, '41854^NOTHING 2 PACK',   'us_english', 834
execute rdt.rdtAddMsg 141855, 10, '41855^BAD ORDERKEY',     'us_english', 834
execute rdt.rdtAddMsg 141856, 10, '41856^NOTHING 2 PACK',   'us_english', 834
execute rdt.rdtAddMsg 141857, 10, '41857^BAD PICKSLIP',     'us_english', 834
execute rdt.rdtAddMsg 141858, 10, '41858^NOTHING 2 PACK',   'us_english', 834


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141851 AND 141900