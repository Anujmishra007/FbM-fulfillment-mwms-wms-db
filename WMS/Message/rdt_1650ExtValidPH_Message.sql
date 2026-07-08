-- 273051 - 273100

rdt.rdtDropMsg 273051 , 273100

execute rdt.rdtAddMsg 273051, 10, '273051^Invalid Door',             'us_english', 1650
execute rdt.rdtAddMsg 273052, 10, '273052^Invalid Door',             'us_english', 1650
execute rdt.rdtAddMsg 273053, 10, '273053^No Order Found',           'us_english', 1650
execute rdt.rdtAddMsg 273054, 10, '273054^Pallet Not in Dock Lane',  'us_english', 1650
execute rdt.rdtAddMsg 273055, 10, '273055^No mbol create',           'us_english', 1650
execute rdt.rdtAddMsg 273056, 10, '273056^Not allow scan',           'us_english', 1650
execute rdt.rdtAddMsg 273057, 10, '273057^IDLoaded2Door',            'us_english', 1650
execute rdt.rdtAddMsg 273058, 10, '273058^Partial Picked',           'us_english', 1650
execute rdt.rdtAddMsg 273059, 10, '273059^Invalid Door',             'us_english', 1650
execute rdt.rdtAddMsg 273060, 10, '273060^ALL PALLETS LOADED',       'us_english', 1650
execute rdt.rdtAddMsg 273061, 10, '273061^ALL PALLETS LOADED',       'us_english', 1650
execute rdt.rdtAddMsg 273062, 10, '273062^PLEASE CHOOSE',            'us_english', 1650
execute rdt.rdtAddMsg 273063, 10, '273063^OPTION 1',                 'us_english', 1650
execute rdt.rdtAddMsg 273064, 10, '273064^There Are Pallets',        'us_english', 1650
execute rdt.rdtAddMsg 273065, 10, '273065^Not Scanned To Door',      'us_english', 1650
execute rdt.rdtAddMsg 273066, 10, '273066^Cannot Close',             'us_english', 1650
execute rdt.rdtAddMsg 273067, 10, '273067^Cannot Close Truck',       'us_english', 1650


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 273051 AND 273100