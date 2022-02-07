--isp515LblNoDecode01
execute rdt.rdtDropMsg 158151, 158200


execute rdt.rdtAddMsg 158151, 10, '158151^InvalidStatus',   'us_english', 515
execute rdt.rdtAddMsg 158152, 10, '158152^SKU SNOCapOff',   'us_english', 515
execute rdt.rdtAddMsg 158153, 10, '158153^Not a SNO    ',   'us_english', 515
execute rdt.rdtAddMsg 158154, 10, '158154^Duplicate SNO',   'us_english', 515


SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 158151 AND 158200