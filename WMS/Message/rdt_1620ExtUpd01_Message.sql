--rdt_1620ExtUpd01
execute rdt.rdtdropmsg 205551 , 205600

execute rdt.rdtAddMsg 205551, 10, '205551 UPD CASE FAIL',   'us_english', 1620
execute rdt.rdtAddMsg 205552, 10, '205552 UPD CASE FAIL',   'us_english', 1620
execute rdt.rdtAddMsg 205553, 10, '205553 GET PDKEY FAIL',  'us_english', 1620
execute rdt.rdtAddMsg 205554, 10, '205554 INS PDTL FAIL',   'us_english', 1620
execute rdt.rdtAddMsg 205555, 10, '205555 UPD CASE FAIL',   'us_english', 1620

select * from rdt.rdtmsg (nolock) where Message_ID BETWEEN 205551 AND 205600
