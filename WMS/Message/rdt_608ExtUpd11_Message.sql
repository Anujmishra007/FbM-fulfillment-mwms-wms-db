--rdt_608ExtUpd11
execute rdt.rdtDropMsg 161251 , 161300

execute rdt.rdtAddMsg 161251, 10, '61251^Upd ASN Fail',     'us_english',  608

SELECT * FROM RDT.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 161251 AND 161300