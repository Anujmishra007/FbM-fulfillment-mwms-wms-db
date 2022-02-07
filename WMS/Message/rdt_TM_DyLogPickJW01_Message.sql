--rdt_TM_DyLogPickJW01
--execute rdt.rdtdropmsg 50201 , 50250

execute rdt.rdtAddMsg '50201', 10, '50201^InsDropIDFail',   'us_english'
execute rdt.rdtAddMsg '50202', 10, '50202^InsDpIDDetFail',  'us_english'
execute rdt.rdtAddMsg '50203', 10, '50203^GenPkSlipFail',   'us_english'
execute rdt.rdtAddMsg '50204', 10, '50204^UpdPickHdrFail',  'us_english'
execute rdt.rdtAddMsg '50205', 10, '50205^ScanInFail',      'us_english'
execute rdt.rdtAddMsg '50206', 10, '50206^UpdPickDtlFail',  'us_english'
execute rdt.rdtAddMsg '50207', 10, '50207^GenPickkeyErr',   'us_english'
execute rdt.rdtAddMsg '50208', 10, '50208^UpdPickDtlFail',  'us_english'
execute rdt.rdtAddMsg '50209', 10, '50209^InsPickDtlFail',  'us_english'
execute rdt.rdtAddMsg '50210', 10, '50210^DelDIDDetFail',  'us_english'
execute rdt.rdtAddMsg '50211', 10, '50211^DelDropIDFail',  'us_english'
execute rdt.rdtAddMsg '50212', 10, '50212^InsertUCCFail',  'us_english'
execute rdt.rdtAddMsg '50213', 10, '50213^InsDPKLogFail',  'us_english'
execute rdt.rdtAddMsg '50214', 10, '50214^UpdDPKLogFai',  'us_english'

--SOS326850
execute rdt.rdtAddMsg '50215', 10, '50215^GetWCSKey Fail',  'us_english'
execute rdt.rdtAddMsg '50216', 10, '50216^CrtRouteFail',    'us_english'
execute rdt.rdtAddMsg '50217', 10, '50217^UpdRouteFail',    'us_english'
execute rdt.rdtAddMsg '50218', 10, '50218^CrtRouteFail',    'us_english'

--SOS332896
execute rdt.rdtAddMsg '50219', 10, '50219^InsDPKLogFai',    'us_english'
execute rdt.rdtAddMsg '50220', 10, '50220^UpdLotLocIDFail', 'us_english'
execute rdt.rdtAddMsg '50221', 10, '50221^InsDPKLogFai',    'us_english'
execute rdt.rdtAddMsg '50222', 10, '50222^UpdLotLocIDFail', 'us_english'
execute rdt.rdtAddMsg '50223', 10, '50223^FailToFindINV',   'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 50201 AND 50250