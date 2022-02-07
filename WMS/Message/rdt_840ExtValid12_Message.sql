--rdt_840ExtValid12
rdt.rdtDropMsg 171351 , 171400

execute rdt.rdtAddMsg 171351, 10, 'ORDER CANCELLED',        'us_english', 840
execute rdt.rdtAddMsg 171352, 10, 'PLS USE BOX',            'us_english', 840
execute rdt.rdtAddMsg 171353, 10, 'PLS USE GWP',            'us_english', 840
execute rdt.rdtAddMsg 171354, 10, 'ORDER CANCELLED',        'us_english', 840
execute rdt.rdtAddMsg 171355, 10, '171355 INVALID LOT02',   'us_english', 840
execute rdt.rdtAddMsg 171356, 10, '171356 Upd OdDtl Err',   'us_english', 840
execute rdt.rdtAddMsg 171357, 10, '171357 Upd OdHdr Err',   'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 171351 AND 171400