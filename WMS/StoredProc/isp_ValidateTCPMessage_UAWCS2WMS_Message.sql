--isp_ValidateTCPMessage_UAWCS2WMS
execute rdt.rdtDropMsg 141951 , 142000	

execute rdt.rdtAddMsg 141951, 10, '41951^TCP Socket Err',   'us_english', 0
execute rdt.rdtAddMsg 141952, 10, '41952^DROPID EXISTS',    'us_english', 0
execute rdt.rdtAddMsg 141953, 10, '41953^INS DROPID Err',   'us_english', 0
execute rdt.rdtAddMsg 141954, 10, '41954^DROPDT EXISTS',    'us_english', 0
execute rdt.rdtAddMsg 141955, 10, '41955^INS DROPDT Err',   'us_english', 0

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141951 AND 142000	


