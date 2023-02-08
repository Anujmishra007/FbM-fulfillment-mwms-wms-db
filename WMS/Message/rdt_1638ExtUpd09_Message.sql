--rdt_1638ExtUpd09
execute rdt.rdtDropMsg 193801 , 193850	

execute rdt.rdtAddMsg 193801, 10, '193801 No LoadKey   ',   'us_english', 1638
execute rdt.rdtAddMsg 193802, 10, '193802 NO ORDERKEY  ',   'us_english', 1638
execute rdt.rdtAddMsg 193803, 10, '193803 INS MBOL Fail',   'us_english', 1638
execute rdt.rdtAddMsg 193804, 10, '193804 MBOL shipped ',   'us_english', 1638
execute rdt.rdtAddMsg 193805, 10, '193805 MBOL FAC Diff',   'us_english', 1638
execute rdt.rdtAddMsg 193806, 10, '193806INS MBDtl Fail',   'us_english', 1638
execute rdt.rdtAddMsg 193807, 10, '193807 UPD MBOL Fail',   'us_english', 1638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 193801 AND 193850	

