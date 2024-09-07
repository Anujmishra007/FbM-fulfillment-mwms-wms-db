-- rdt_593CartonLabel01
-- FCR-727
exec rdt.rdtDropMsg 222401, 222450

execute rdt.rdtAddMsg 222401, 10, '222401LabelNoNeeded',       'us_english', 593
execute rdt.rdtAddMsg 222402, 10, '222402InvalidLabelNo',      'us_english', 593
execute rdt.rdtAddMsg 222403, 10, '222403NoLabelPrint',        'us_english', 593


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 222401 AND 222450