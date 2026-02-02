
-- rdt_1855CfmToLoc01
--237901 - 237950

execute rdt.rdtDropMsg 237901, 237950

execute rdt.rdtAddMsg 237901, 10, '237901 GroupkeyEmpty',   'us_english', 1855, 0, '237901 Groupkey is empty'
execute rdt.rdtAddMsg 237902, 10, '237902 CartIDEmpty',     'us_english', 1855, 0, '237902 CartID is empty'
execute rdt.rdtAddMsg 237903, 10, '237903 UpdTaskFail',     'us_english', 1855, 0, '237903 Update task failed'

/* 2025-08-19 1.1.0 NickT      UWP-39586 Performance tuning             */
execute rdt.rdtAddMsg 237904, 10, '237904 UpdTaskFail',     'us_english', 1855, 0, '237904 Update task failed'

select * from rdt.rdtmsg (nolock) where message_id between '237901' and '237950'
