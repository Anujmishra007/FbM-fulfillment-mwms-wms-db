


select * from rdt.rdtmsg (nolock) where message_id between '173951' and '174000'

-- rdt_1855CfmToLoc01
execute rdt.rdtDropMsg 173951, 174000

execute rdt.rdtAddMsg 173951, 10, '173951 Confirm Fail  ', 'us_english', 1855
execute rdt.rdtAddMsg 173952, 10, '173952 Upd CaseID Er ', 'us_english', 1855