--rdt_898ExtScn09
--execute rdt.rdtdropmsg 267401 - 267450
execute rdt.rdtDropMsg 267401, 267450

execute rdt.rdtAddMsg 267401 ,10, '267401^CodeRequired',    'us_english', 898, 0, '267401: COND CODE is required'
execute rdt.rdtAddMsg 267402 ,10, '267402^BadCONDCode',     'us_english', 898, 0, '267402: Invalid Condition Code'
execute rdt.rdtAddMsg 267403 ,10, '267403^UpdCONDCodeFail', 'us_english', 898, 0, '267403: Update MOBREC Failed'

select * from rdt.rdtmsg (nolock) where message_id between 267401 and 267450
