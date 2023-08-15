--rdt_855ExtValid05
rdt.rdtDropMsg 204351 , 204400

execute rdt.rdtAddMsg 204351, 10, '204351CartonNotPick     ',    'us_english', 855

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 204351 AND 204400