-- rdt_840ExtValid06
execute rdt.rdtDropMsg 146051 , 146100

execute rdt.rdtAddMsg 146051, 10, '46051^INV CTN TYPE',     'us_english', 840

--WMS-14288
execute rdt.rdtAddMsg 146052, 10, '46052^HMORD# X MATCH',   'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 146051 AND 146100
