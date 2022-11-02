--rdt_640ExtUpd02
execute rdt.rdtDropMsg 193251 , 193300

execute rdt.rdtAddMsg 193251, 10, '187551UPD WKORDER ER',   'us_english', 640
execute rdt.rdtAddMsg 193252, 10, '187552UPD WKORDER ER',   'us_english', 640


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 193251 AND 193300


