--rdt_839ExtValidSP07
rdt.rdtDropMsg 170401 , 170450	

execute rdt.rdtAddMsg 170401, 10, '170401PSNOInProgress',   'us_english', 839
execute rdt.rdtAddMsg 170402, 10, '170402ZoneInProgress',   'us_english', 839
execute rdt.rdtAddMsg 170403, 10, '170403ZoneInProgress',   'us_english', 839

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 170401 AND 170450