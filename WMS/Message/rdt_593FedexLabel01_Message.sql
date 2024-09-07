-- rdt_593FedexLabel01
-- FCR-727
exec rdt.rdtDropMsg 223001, 223050

execute rdt.rdtAddMsg 223001, 10, '223001LabelNoNeeded',       'us_english', 593
execute rdt.rdtAddMsg 223002, 10, '223002InvalidLabel',        'us_english', 593
execute rdt.rdtAddMsg 223003, 10, '223003DiffSCAC',            'us_english', 593
execute rdt.rdtAddMsg 223004, 10, '223004GenTranLogFail',      'us_english', 593
execute rdt.rdtAddMsg 223005, 10, '223005QCmdFail',            'us_english', 593
execute rdt.rdtAddMsg 223006, 10, '223006NoCODELKUP',          'us_english', 593

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 223001 AND 223050