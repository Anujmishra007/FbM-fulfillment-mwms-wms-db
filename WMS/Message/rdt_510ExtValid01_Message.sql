--rdt_510ExtValid01
rdt.rdtDropMsg 160201 , 160250	

execute rdt.rdtAddMsg 160201, 10, '60201^Cannot Mix Sku', 'us_english', 510
execute rdt.rdtAddMsg 160202, 10, '60202^Invalid To Loc', 'us_english', 510

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 160201 AND 160250
