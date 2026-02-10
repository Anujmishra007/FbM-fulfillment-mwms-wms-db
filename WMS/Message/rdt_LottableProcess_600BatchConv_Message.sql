-- rdt_LottableProcess_600BatchConv (NYE018)
-- 256351 - 256400

execute rdt.rdtdropmsg 256351, 256400

execute rdt.rdtAddMsg 256351, 10, '256351InvalidBatchCodeLength',   'us_english', 600, 0, '256351: Invalid BatchCode Length'
execute rdt.rdtAddMsg 256352, 10, '256352InvalidBatchCodeNumeric',  'us_english', 600, 0, '256352: Invalid BatchCode Numeric'
execute rdt.rdtAddMsg 256353, 10, '256353InvalidBatchMonth',        'us_english', 600, 0, '256353: Invalid Batch Month'

select * from rdt.rdtmsg (nolock) where message_id between 256351 and 256400