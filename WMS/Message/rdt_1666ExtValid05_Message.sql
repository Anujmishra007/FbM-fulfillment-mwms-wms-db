--rdt_1666ExtValid05
rdt.rdtDropMsg 178601, 178650

execute rdt.rdtAddMsg 178601, 10, '178601^ > MBOLKey   ',    'us_english', 1666
execute rdt.rdtAddMsg 178602, 10, '178602^PltID Scanned',    'us_english', 1666
execute rdt.rdtAddMsg 178603, 10, '178603^Diff MBol Grp',    'us_english', 1666

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 178601 AND 178650