--rdt_593CatlogLabel01
--FCR-727
EXEC rdt.rdtDropMsg 222351, 222400

EXECUTE rdt.rdtAddMsg 222351, 10, '222351LabelNoNeeded',          'us_english', 593
EXECUTE rdt.rdtAddMsg 222352, 10, '222352InvalidLabelNo',         'us_english', 593
EXECUTE rdt.rdtAddMsg 222353, 10, '222353SKUNeeded',              'us_english', 593
EXECUTE rdt.rdtAddMsg 222354, 10, '222354InvalidSKU',             'us_english', 593
EXECUTE rdt.rdtAddMsg 222355, 10, '222355InvalidQty',             'us_english', 593
EXECUTE rdt.rdtAddMsg 222356, 10, '222356NoLabelPrint',           'us_english', 593


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 222351 AND 222400