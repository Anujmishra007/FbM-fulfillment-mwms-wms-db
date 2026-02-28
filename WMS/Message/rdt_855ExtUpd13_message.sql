--rdt_855ExtUpd13
rdt.rdtDropMsg 217801, 217850

EXECUTE rdt.rdtAddMsg 217801, 10, '217801GenTranLogFail',         'us_english', 855
EXECUTE rdt.rdtAddMsg 217802, 10, '217802QCmdFail',               'us_english', 855
EXECUTE rdt.rdtAddMsg 217803, 10, '217803HandlePPAFail',          'us_english', 855
EXECUTE rdt.rdtAddMsg 217804, 10, '217804NoPrinter',              'us_english', 855
EXECUTE rdt.rdtAddMsg 217805, 10, '217805NoPrinter',              'us_english', 855
EXECUTE rdt.rdtAddMsg 217806, 10, '217806NoPrinter',              'us_english', 855
EXECUTE rdt.rdtAddMsg 217807, 10, '217807^FailToGetRefID',        'us_english', 855, 0, '217807: Failed to get reference id'
EXECUTE rdt.rdtAddMsg 217808, 10, '217808^UpdOrderInfoFail',      'us_english', 855, 0, '217808: Update OrderInfo failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 217801 AND 217850