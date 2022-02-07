-- rdtfnc_Capture_SKUInfo
rdt.rdtDropMsg 132051 , 132100

execute rdt.rdtAddMsg 132051, 10, '32051^Value req',       'us_english', 826
execute rdt.rdtAddMsg 132052, 10, '32052^Either UCC/SKU',  'us_english', 826
execute rdt.rdtAddMsg 132053, 10, '32053^Invalid Format',  'us_english', 826
execute rdt.rdtAddMsg 132054, 10, '32054^Invalid UCC',     'us_english', 826
execute rdt.rdtAddMsg 132055, 10, '32055^Invalid SKU',     'us_english', 826
execute rdt.rdtAddMsg 132056, 10, '32056^SameSKUBarcode',  'us_english', 826
execute rdt.rdtAddMsg 132057, 10, '32057^Invalid Qty',     'us_english', 826
execute rdt.rdtAddMsg 132058, 10, '32058^Param NotSetup',  'us_english', 826
execute rdt.rdtAddMsg 132059, 10, '32059^Value req',       'us_english', 826
execute rdt.rdtAddMsg 132060, 10, '32060^Value req',       'us_english', 826
execute rdt.rdtAddMsg 132061, 10, '32061^Validate Err',    'us_english', 826

--wms-16159
execute rdt.rdtAddMsg 132062, 10, '32062^Need Option',    'us_english', 826
execute rdt.rdtAddMsg 132063, 10, '32063^Invalid Option', 'us_english', 826

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 132051 AND 132100