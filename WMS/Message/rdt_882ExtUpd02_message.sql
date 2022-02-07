



SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '178201' AND '178250'


--rdt_882ExtUpd02
EXEC rdt.rdtDropMsg 178201, 178250

execute rdt.rdtAddMsg 178201, 10, '178201Update Sort Err',   'us_english', 882
execute rdt.rdtAddMsg 178202, 10, '178202Delete Sort Err',   'us_english', 882
execute rdt.rdtAddMsg 178203, 10, '178203Delete UCC Err',   'us_english', 882