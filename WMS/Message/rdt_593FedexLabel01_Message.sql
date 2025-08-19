-- rdt_593FedexLabel01
-- FCR-727
exec rdt.rdtDropMsg 223001, 223050

execute rdt.rdtAddMsg 223001, 10, '223001LabelNoNeeded',       'us_english', 593
execute rdt.rdtAddMsg 223002, 10, '223002InvalidLabel',        'us_english', 593
execute rdt.rdtAddMsg 223003, 10, '223003DiffSCAC',            'us_english', 593
execute rdt.rdtAddMsg 223004, 10, '223004GenTranLogFail',      'us_english', 593
execute rdt.rdtAddMsg 223005, 10, '223005QCmdFail',            'us_english', 593
execute rdt.rdtAddMsg 223006, 10, '223006NoCODELKUP',          'us_english', 593
execute rdt.rdtAddMsg 223007, 10, '223007CreateBolSeqNoFail',  'us_english', 593, 0, '223007: Create BOL sequence number failed.'
execute rdt.rdtAddMsg 223008, 10, '223008UpdOrdInfoFail',      'us_english', 593, 0, '223008: Update orderinfo failed'
execute rdt.rdtAddMsg 223009, 10, '223009CreateBolSeqNoFail',  'us_english', 593, 0, '223009: Create BOL sequence number failed.'
execute rdt.rdtAddMsg 223010, 10, '223010UpdOrdInfoFail',      'us_english', 593, 0, '223010: Update orderinfo failed'
execute rdt.rdtAddMsg 223011, 10, '223011PickNotFinished',      'us_english', 593, 0, '223011: Pick Not Finished'
execute rdt.rdtAddMsg 223012, 10, '223012PackNotFinished',      'us_english', 593, 0, '223012: Pack Not Finished'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 223001 AND 223050