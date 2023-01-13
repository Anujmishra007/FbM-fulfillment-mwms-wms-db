--rdt_839ExtValidSP12
EXEC rdt.rdtDropMsg 194701 , 194750	

execute rdt.rdtAddMsg 194701, 10, '194701 VP Picked    ',   'us_english', 1856
execute rdt.rdtAddMsg 194702, 10, '194702Cannot ShtPick',   'us_english', 1856
execute rdt.rdtAddMsg 194703, 10, '194703Cannot SkipLoc',   'us_english', 1856

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 194701 AND 194750	