--rdtLogin
execute rdt.rdtdropmsg 221151, 221200

execute rdt.rdtAddMsg 221151, 10, '221151ReachMaxRetry', 'us_english', 0, 0, 'Reach Maximum Retry Times. Wait 30 seconds'

select * from rdt.rdtmsg where message_id between 221151 and 221200