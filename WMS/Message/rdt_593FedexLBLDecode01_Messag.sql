exec rdt.rdtDropMsg 237601 , 237650

execute rdt.rdtAddMsg 237601, 10, '237601^Print Data Error',   'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 237601 AND 237650

