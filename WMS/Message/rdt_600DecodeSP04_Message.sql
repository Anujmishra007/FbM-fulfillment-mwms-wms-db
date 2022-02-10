-- rdt_600DecodeSP04
execute rdt.rdtDropMsg 130851, 130900

execute rdt.rdtAddMsg 130851, 10, '30851^SKU Not Found ', 'us_english', 600
execute rdt.rdtAddMsg 130852, 10, '30852^X Mat/Grid/Cat', 'us_english', 600
execute rdt.rdtAddMsg 130853, 10, '30853^Invalid Batch ', 'us_english', 600
execute rdt.rdtAddMsg 130854, 10, '30854^Required SSCC ', 'us_english', 600
execute rdt.rdtAddMsg 130855, 10, '30855^Invalid Barcod', 'us_english', 600

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130851 AND 130900