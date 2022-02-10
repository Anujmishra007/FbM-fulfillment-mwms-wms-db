--rdt_608ExtVal05
rdt.rdtDropMsg 141251 , 141300

execute rdt.rdtAddMsg 141251, 10, '41251^SKU Not in ASN',   'us_english', 608

--WMS9091
execute rdt.rdtAddMsg 141252, 10, '41252^OverReceipt',      'us_english', 608

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141251 AND 141300