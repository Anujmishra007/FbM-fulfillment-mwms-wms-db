-- rdtfnc_Inquiry_V7
rdt.rdtDropMsg 123251 , 123300

execute rdt.rdtAddMsg 123251, 10, '23251^Value needed',   'us_english', 628
execute rdt.rdtAddMsg 123252, 10, '23252^ID/LOC/SKUOnly', 'us_english', 628
execute rdt.rdtAddMsg 123253, 10, '23253^Invalid LOC',    'us_english', 628
execute rdt.rdtAddMsg 123254, 10, '23254^Diff facility',  'us_english', 628
execute rdt.rdtAddMsg 123255, 10, '23255^Invalid ID',     'us_english', 628
execute rdt.rdtAddMsg 123256, 10, '23256^Invalid SKU',    'us_english', 628

--WMS7485
execute rdt.rdtAddMsg 123257, 10, '23257^Invalid SKU',    'us_english', 628
execute rdt.rdtAddMsg 123258, 10, '23258^MultiSKUBarcod', 'us_english', 628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 123251 AND 123300