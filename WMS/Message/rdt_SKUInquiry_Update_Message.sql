--rdt_SKUInquiry_Update
execute rdt.rdtDropMsg 187551 , 187600

execute rdt.rdtAddMsg 187551, 10, '187551UPD CASECNT ER',   'us_english', 556
execute rdt.rdtAddMsg 187552, 10, 'SKU CASECNT UPDATED ',   'us_english', 556

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 187551 AND 187600


