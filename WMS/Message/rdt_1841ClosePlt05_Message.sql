--rdt_1841ExtScn01
--FCR-9027
execute rdt.rdtdropmsg 252451, 252500

execute rdt.rdtAddMsg 252451, 10, '252451^BadStrategyKey',     'us_english', 1841
execute rdt.rdtAddMsg 252452, 10, '252452^BadStrategyKey',     'us_english', 1841
execute rdt.rdtAddMsg 252453, 10, '252453^GetKeyFail',         'us_english', 1841
execute rdt.rdtAddMsg 252454, 10, '252454^InsTaskFail',        'us_english', 1841
execute rdt.rdtAddMsg 252455, 10, '252455^ClosePltFail',       'us_english', 1841
execute rdt.rdtAddMsg 252456, 10, '252456^InsUCCFail',         'us_english', 1841, 0, '252456 Create new UCC Failed'
execute rdt.rdtAddMsg 252457, 10, '252457^UpdUCCFail',         'us_english', 1841, 0, '252457 Update new UCC Failed'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 252451 AND 252500