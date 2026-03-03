--rdt_1764ExtScn03
--256201 - 256250

execute rdt.rdtdropmsg 256201 , 256250

execute rdt.rdtAddMsg 256201, 10, '256201 InvReason',       'us_english', 1764, 0, '256201 Invalid default reason'
execute rdt.rdtAddMsg 256202, 10, '256202 InsSkipTskFail',  'us_english', 1764, 0, '256202 Insert Skip task fail'
execute rdt.rdtAddMsg 256203, 10, '256203 UpdTaskFail',     'us_english', 1764, 0, '256203 Update task fail'
execute rdt.rdtAddMsg 256204, 10, '256204 UpdTaskFail',     'us_english', 1764, 0, '256204 Update task fail'
execute rdt.rdtAddMsg 256205, 10, '256205 DelRFLogFail',    'us_english', 1764, 0, '256205 Delete RFLog fail'
execute rdt.rdtAddMsg 256206, 10, '256206 RelloRetryEmpty', 'us_english', 1764, 0, '256206 RealloNumberofRetry config is not enabled'
execute rdt.rdtAddMsg 256207, 10, '256207 InvRelloRetry',   'us_english', 1764, 0, '256207 RealloNumberofRetry must be numeric'
execute rdt.rdtAddMsg 256208, 10, '256208 InvalidOption',   'us_english', 1764, 0, '256208 Option 9 is disabled'
execute rdt.rdtAddMsg 256209, 10, '256209 InvalidOption',   'us_english', 1764, 0, '256209 Option 9 is disabled'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 256201 AND 256250