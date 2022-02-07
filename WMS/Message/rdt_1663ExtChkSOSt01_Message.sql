--rdt_1663ExtChkSOSt01
rdt.rdtDropMsg 143151 , 143200

execute rdt.rdtAddMsg 143151, 10, '43151^Order on HOLD',    'us_english', 1663
execute rdt.rdtAddMsg 143152, 10, '43152^Pending Update',   'us_english', 1663
execute rdt.rdtAddMsg 143153, 10, '43153^Pending CANC',     'us_english', 1663
execute rdt.rdtAddMsg 143154, 10, '43154^Order CANCEL',     'us_english', 1663
execute rdt.rdtAddMsg 143155, 10, '43155^OrderPACK&HOLD',   'us_english', 1663
execute rdt.rdtAddMsg 143156, 10, '43156^Pending Hold',     'us_english', 1663
execute rdt.rdtAddMsg 143157, 10, '43157^Status blocked',   'us_english', 1663


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 143151 AND 143200