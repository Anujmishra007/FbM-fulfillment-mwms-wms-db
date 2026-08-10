-- rdt_1812ExtUpd08
-- 276951 - 277000

execute rdt.rdtDropMsg 276951, 277000

execute rdt.rdtAddMsg 276951, 10, '276951^UpdTaskFail', 'us_english', 1812, 0, '276951: Update TaskDetail Fails'

select * from rdt.rdtmsg (nolock) where message_id between 276951 and 277000
