-- rdt_600ExtVal03_Message
execute rdt.rdtDropMsg 103651 , 103700

execute rdt.rdtAddMsg 103651, 10, '03651^NOT ALLOW > 1',   'us_english', 600
execute rdt.rdtAddMsg 103652, 10, '03652^STOCK EXISTS',    'us_english', 600
execute rdt.rdtAddMsg 103653, 10, '03653^STOCK RECEIVED',  'us_english', 600

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 103651 AND 103700
