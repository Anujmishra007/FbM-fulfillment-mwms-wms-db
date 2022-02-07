--rdt_832ExtValid01
rdt.rdtDropMsg 144851 , 144900

execute rdt.rdtAddMsg 144851, 10, '44851^Invalid PKSlip',   'us_english', 832
execute rdt.rdtAddMsg 144852, 10, '44852^Nothing 2 Pack',   'us_english', 832
execute rdt.rdtAddMsg 144853, 10, '44853^Invalid UPC',      'us_english', 832
execute rdt.rdtAddMsg 144854, 10, '44854^Invalid UOM',      'us_english', 832
execute rdt.rdtAddMsg 144855, 10, '44855^Setup CaseCnt',    'us_english', 832

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 144851 AND 144900