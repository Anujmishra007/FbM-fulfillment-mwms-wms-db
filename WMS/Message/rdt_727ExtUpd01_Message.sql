--rdt_727ExtUpd01
rdt.rdtDropMsg 141351 , 141400

execute rdt.rdtAddMsg 141351, 10, '41351^CTN Not Exists',   'us_english', 727
execute rdt.rdtAddMsg 141352, 10, '41352^UPD CTN Fail',     'us_english', 727

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141351 AND 141400