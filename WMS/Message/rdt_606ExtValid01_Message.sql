--rdt_606ExtValid01
execute rdt.rdtDropMsg 137601, 137650

execute rdt.rdtAddMsg 137601, 10, '37601^Invalid Field', 'us_english', 606
execute rdt.rdtAddMsg 137602, 10, '37602^Inv Data Type', 'us_english', 606

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137601 AND 137650
