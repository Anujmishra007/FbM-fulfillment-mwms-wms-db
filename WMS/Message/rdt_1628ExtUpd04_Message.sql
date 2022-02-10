--rdt_1628ExtUpd04
rdt.rdtDropMsg 166451 , 166500	

execute rdt.rdtAddMsg 166451, 10, '166451ShortPICK Fail', 'us_english', 1628
execute rdt.rdtAddMsg 166452, 10, '166452ShortPICK Fail', 'us_english', 1628
execute rdt.rdtAddMsg 166453, 10, '166453 Ecom Pack Cfm', 'us_english', 1628
execute rdt.rdtAddMsg 166454, 10, '166454Del PackH Fail', 'us_english', 1628
execute rdt.rdtAddMsg 166455, 10, '166455DelPickInfFail', 'us_english', 1628


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 166451 AND 166500
