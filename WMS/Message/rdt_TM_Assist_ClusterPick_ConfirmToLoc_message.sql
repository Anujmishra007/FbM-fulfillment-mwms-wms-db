

select * from rdt.rdtmsg (nolock) where message_id between '171901' and '171950'

-- rdt_TM_Assist_ClusterPick_ConfirmToLoc
execute rdt.rdtDropMsg 171901, 171950

execute rdt.rdtAddMsg 171901, 10, '171901 Confirm Fail ', 'us_english', 1855