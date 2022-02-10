--rdt_862ExtValid01
exec rdt.rdtDropMsg 121851 , 121900

execute rdt.rdtAddMsg 121851, 10, '21851^ID Not Fully',     'us_english', 862
execute rdt.rdtAddMsg 121852, 10, '21852^Allocated And',    'us_english', 862
execute rdt.rdtAddMsg 121853, 10, '21853^Mix Serial No',    'us_english', 862
execute rdt.rdtAddMsg 121854, 10, '21854^Pls Pick By',      'us_english', 862
execute rdt.rdtAddMsg 121855, 10, '21855^SKU/UPC (860)',    'us_english', 862

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 121851 AND 121900
