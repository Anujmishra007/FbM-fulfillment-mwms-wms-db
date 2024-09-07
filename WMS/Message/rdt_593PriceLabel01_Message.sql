--rdt_593PriceLabel01
--FCR-727
EXEC rdt.rdtDropMsg 222251, 222300

EXECUTE rdt.rdtAddMsg 222251, 10, '222251LabelNoNeeded',          'us_english', 593
EXECUTE rdt.rdtAddMsg 222252, 10, '222252InvalidLabelNo',         'us_english', 593
EXECUTE rdt.rdtAddMsg 222253, 10, '222253SKUNeeded',              'us_english', 593
EXECUTE rdt.rdtAddMsg 222254, 10, '222254InvalidSKU',             'us_english', 593
EXECUTE rdt.rdtAddMsg 222255, 10, '222255InvalidQty',             'us_english', 593
EXECUTE rdt.rdtAddMsg 222256, 10, '222256NoLabelPrint',           'us_english', 593


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 222251 AND 222300