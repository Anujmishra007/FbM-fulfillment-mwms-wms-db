--rdt_1663ExtUpd06
EXEC rdt.rdtDropMsg 156251 , 156300	

execute rdt.rdtAddMsg 156251, 10, '56251^Gen TLOG3 Fail', 'us_english', 1663
execute rdt.rdtAddMsg 156252, 10, '56252^No PickSlip',    'us_english', 1663
execute rdt.rdtAddMsg 156253, 10, '56253^INSPackInfFail', 'us_english', 1663
execute rdt.rdtAddMsg 156254, 10, '56254^UPDPackInfFail', 'us_english', 1663

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 156251 AND 156300
