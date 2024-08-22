
--FCR-392
exec rdt.rdtdropmsg 221601, 221650

execute rdt.rdtAddMsg 221601, 10, '221601NotAllowEsc', 'us_english', 838, 0, '211601 Cannot Exit In Repack'

select * from rdt.rdtmsg (nolock) where message_id between 221601 AND 221650