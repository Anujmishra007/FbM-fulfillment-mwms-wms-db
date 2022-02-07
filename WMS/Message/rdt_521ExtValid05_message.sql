
SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '177851' AND '177900'

--rdt_521ExtValid05
EXEC rdt.rdtDropMsg 177851, 177900

execute rdt.rdtAddMsg 177851, 10, 'With Pending ',   'us_english', 521
execute rdt.rdtAddMsg 177852, 10, 'ASTRPT Task  ',   'us_english', 521