

select * from rdt.rdtmsg (nolock) where message_id between '171851' and '171900'

-- rdt_TM_Assist_ClusterPick_GetTask
execute rdt.rdtDropMsg 171851, 171900

execute rdt.rdtAddMsg 171851, 10, '171851 No Task   ', 'us_english', 1855