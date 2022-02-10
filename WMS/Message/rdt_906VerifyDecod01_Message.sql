--rdt_906DecodeSP01
 execute rdt.rdtDropMsg 136901, 136950

execute rdt.rdtAddMsg 136901, 10, '36901^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 136902, 10, '36902^MultiSKUBarcod', 'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 136901 AND 136950