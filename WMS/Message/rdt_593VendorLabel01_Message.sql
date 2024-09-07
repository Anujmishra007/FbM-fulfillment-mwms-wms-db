--rdt_855ExtUpd13
--FCR-727
rdt.rdtDropMsg 222301, 222350

EXECUTE rdt.rdtAddMsg 222301, 10, '222301LabelNoNeeded',             'us_english', 855
EXECUTE rdt.rdtAddMsg 222302, 10, '222302InvalidLabelNo',            'us_english', 855
EXECUTE rdt.rdtAddMsg 222303, 10, '222303NoLabelPrint',              'us_english', 855

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 222301 AND 222350