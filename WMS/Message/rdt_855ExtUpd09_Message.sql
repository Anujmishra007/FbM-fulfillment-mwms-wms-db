--rdt_855ExtUpd09
execute rdt.rdtDropMsg 201751 , 201800

execute rdt.rdtAddMsg 201751, 10, '201751 UPD ORD FAIL ',   'us_english', 855
execute rdt.rdtAddMsg 201752, 10, '201752 UPD PACK FAIL',   'us_english', 855
execute rdt.rdtAddMsg 201753, 10, '201753 UPD PPA FAIL ',   'us_english', 855

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 201751 AND 201800


