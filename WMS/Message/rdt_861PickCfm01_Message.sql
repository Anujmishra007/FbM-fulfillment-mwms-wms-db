-- rdt_PickAndPack_ConfirmTask (range 234051 - 234100)
-- FCR-2519
execute rdt.rdtDropMsg 234051, 234100

execute rdt.rdtAddMsg 234051, 10, '234051 Bad TaskQTY',    'us_english'
execute rdt.rdtAddMsg 234052, 10, '234052 Bad ConfirmQTY', 'us_english'
execute rdt.rdtAddMsg 234053, 10, '234053 Over pick',      'us_english'
execute rdt.rdtAddMsg 234054, 10, '234054 Bad UCC param',  'us_english'
execute rdt.rdtAddMsg 234055, 10, '234055 Get PKDtl fail', 'us_english'
execute rdt.rdtAddMsg 234056, 10, '234056 Task changed',   'us_english'
execute rdt.rdtAddMsg 234057, 10, '234057 Task changed',   'us_english'
execute rdt.rdtAddMsg 234058, 10, '234058 offset error',   'us_english'
execute rdt.rdtAddMsg 234059, 10, '234059 Upd PKDtl fail', 'us_english'
execute rdt.rdtAddMsg 234060, 10, '234060 Task changed',   'us_english'
execute rdt.rdtAddMsg 234061, 10, '234061 Upd UCC fail',   'us_english'
execute rdt.rdtAddMsg 234062, 10, '234062 Task changed',   'us_english'

execute rdt.rdtAddMsg 234063, 10, '234063^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 234064, 10, '234064^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 234065, 10, '234065^GetDetKeyFail', 'us_english'
execute rdt.rdtAddMsg 234066, 10, '234066^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 234067, 10, '234067^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 234068, 10, '234068^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 234069, 10, '234069^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 234070, 10, '234070^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 234071, 10, '234071^Ins Alert Fail', 'us_english'
execute rdt.rdtAddMsg 234072, 10, '234072^Scan Out Fail',  'us_english'
execute rdt.rdtAddMsg 234073, 10, '234073^Scan Out Fail',  'us_english'

execute rdt.rdtAddMsg 234074, 10, '234074^InsPDFail',       'us_english'
execute rdt.rdtAddMsg 234075, 10, '234075^UpdPDFail',       'us_english'
execute rdt.rdtAddMsg 234076, 10, '234076^UpdPDFail',       'us_english'
execute rdt.rdtAddMsg 234077, 10, '234077^InsPDFail',       'us_english'
execute rdt.rdtAddMsg 234078, 10, '234078^GetDetKeyFail',   'us_english'
execute rdt.rdtAddMsg 234079, 10, '234079^InsPDFail',       'us_english'
execute rdt.rdtAddMsg 234080, 10, '234080^GetDetKeyFail',   'us_english'
execute rdt.rdtAddMsg 234081, 10, '234081^InsPDFail',       'us_english'


SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 234051 AND 234100