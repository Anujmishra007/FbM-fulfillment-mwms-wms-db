-- rdt_1723DecodCtnSP01
execute rdt.rdtdropmsg 98451 , 98500

execute rdt.rdtAddMsg 98451, 10, '98451^WRONG UPC CODE',    'us_english', 1723
execute rdt.rdtAddMsg 98452, 10, '98452^WRONG UPC CODE',    'us_english', 1723
execute rdt.rdtAddMsg 98453, 10, '98453^ID READ ERROR',     'us_english', 1723
execute rdt.rdtAddMsg 98454, 10, '98454^PLS KEY IN',        'us_english', 1723

-- (james01)
execute rdt.rdtAddMsg 98455, 10, '98455^SETUP CODELKUP',    'us_english', 1723
execute rdt.rdtAddMsg 98456, 10, '98456^INVALID PREFIX',    'us_english', 1723
execute rdt.rdtAddMsg 98457, 10, '98457^INVALID LENGTH',    'us_english', 1723
execute rdt.rdtAddMsg 98458, 10, '98458^INVALID LENGTH',    'us_english', 1723
execute rdt.rdtAddMsg 98459, 10, '98459^INVALID PREFIX',    'us_english', 1723
execute rdt.rdtAddMsg 98460, 10, '98460^INVALID SSCC',      'us_english', 1723

-- WMS5526 (james02)
execute rdt.rdtAddMsg 98461, 10, '98461^ID READ ERROR',     'us_english', 1723
execute rdt.rdtAddMsg 98462, 10, '98462^PLS KEY IN',        'us_english', 1723
execute rdt.rdtAddMsg 98463, 10, '98463^WRONG BATCH',       'us_english', 1723
execute rdt.rdtAddMsg 98464, 10, 'NO ALLOW TO CONSO',       'us_english', 1723
execute rdt.rdtAddMsg 98465, 10, '98465^NOTLAST BOTTLE',    'us_english', 1723
execute rdt.rdtAddMsg 98466, 10, '98466^WRONG BATCH',       'us_english', 1723
execute rdt.rdtAddMsg 98467, 10, 'NO ALLOW TO CONSO',       'us_english', 1723

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 98451 AND 98500

