--rdt_640ExtUpd03
execute rdt.rdtDropMsg 200201 , 200250

execute rdt.rdtAddMsg 200201, 10, '200201 Carton In Use',   'us_english', 640
execute rdt.rdtAddMsg 200202, 10, '200202UPD DropId ERR',   'us_english', 640


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 200201 AND 200250


