-- rdt_1580RefNoLKUP01
execute rdt.rdtDropMsg 118851, 118900

execute rdt.rdtAddMsg 118851, 10, '18851^Invalid RefNo ', 'us_english', 1580
execute rdt.rdtAddMsg 118852, 10, '18852^RefNo NotInASN', 'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 118851 AND 118900
