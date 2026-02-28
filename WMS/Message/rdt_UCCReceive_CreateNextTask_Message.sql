-- rdt_UCCReceive_CreateNextTask
--248101 - 248150

execute rdt.rdtDropMsg 248101, 248150

execute rdt.rdtAddMsg 248101, 10, '248101^CODENotFound',    'us_english', 898, 0, '248101 PATask not created - CODE missing)'
execute rdt.rdtAddMsg 248102, 10, '248102^InvalidCode',     'us_english', 898, 0, '248102 PATask not created - Invalid CODE)'
execute rdt.rdtAddMsg 248103, 10, '248103^GetTaskKeyFail',  'us_english', 898, 0, '248103 PATask not created - TaskKey)'
execute rdt.rdtAddMsg 248104, 10, '248104^InsTaskFail',     'us_english', 898, 0, '248104 PATask not created - InsTaskFail)'

select * from rdt.rdtmsg with (nolock) where message_id between 248101 and 248150