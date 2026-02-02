
--rdt_898ExtVal11
--247101 - 247150
 
EXECUTE rdt.rdtdropmsg 247101, 247150			

EXECUTE rdt.rdtAddMsg 247101, 10, '247101^RcptGrpNotAllow',   'us_english',898, 0, '247101 Receipt Group not allowed'


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 247101 AND 247150