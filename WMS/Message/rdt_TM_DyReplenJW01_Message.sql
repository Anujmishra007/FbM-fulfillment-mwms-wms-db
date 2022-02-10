--rdt_TM_DyReplenJW01
--execute rdt.rdtdropmsg 50251 - 50300

execute rdt.rdtAddMsg '50251', 10, '50251^InsertUCCFail',    'us_english'
execute rdt.rdtAddMsg '50252', 10, '50252^UpdateUCCFail',    'us_english'
execute rdt.rdtAddMsg '50253', 10, '50253^InsDPKLogFai',     'us_english'
execute rdt.rdtAddMsg '50254', 10, '50254^UpdLotLocIDFail',  'us_english'
execute rdt.rdtAddMsg '50255', 10, '50255^InsDPKLogFail',    'us_english'
execute rdt.rdtAddMsg '50256', 10, '50256^FailToFindINV',    'us_english'
execute rdt.rdtAddMsg '50257', 10, '50257^UpdLotLocIDFail',  'us_english'

--SOS326850
execute rdt.rdtAddMsg '50258', 10, '50258^GetWCSKey Fail',  'us_english'
execute rdt.rdtAddMsg '50259', 10, '50259^CrtRouteFail',    'us_english'
execute rdt.rdtAddMsg '50260', 10, '50260^UpdRouteFail',    'us_english'
execute rdt.rdtAddMsg '50261', 10, '50261^CrtRouteFail',    'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 50251 AND 50300