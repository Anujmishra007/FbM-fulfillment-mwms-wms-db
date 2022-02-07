--rdt_808ExtUpd01
exec rdt.rdtdropmsg 54801, 54850

execute rdt.rdtAddMsg 54801, 10, '54801^DEL DID Fail', 'us_english', 808
execute rdt.rdtAddMsg 54802, 10, '54802^INS DID Fail', 'us_english', 808
execute rdt.rdtAddMsg 54803, 10, '54803^Fail scan-in', 'us_english', 808

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 54801 AND 54850


