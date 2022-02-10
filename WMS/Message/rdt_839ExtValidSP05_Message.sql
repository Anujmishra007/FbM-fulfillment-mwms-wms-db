--rdt_839ExtValidSP05
rdt.rdtDropMsg 165851 , 165900

execute rdt.rdtAddMsg 165851, 10, '65851^DropID Required',  'us_english', 839
execute rdt.rdtAddMsg 165852, 10, '65852^DropID Len Err',   'us_english', 839
execute rdt.rdtAddMsg 165853, 10, '65853^Invalid DropID',   'us_english', 839

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 165851 AND 165900