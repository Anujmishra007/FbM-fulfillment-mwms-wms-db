-- 269701 - 269750

execute rdt.rdtdropmsg 269701, 269750

execute rdt.rdtAddMsg 269701, 10, '269701NoTask.ClosePL',   'us_english', 1764, 0, '269701 NoTask.ClosePL'
execute rdt.rdtAddMsg 269702, 10, '269702No more task',     'us_english', 1764, 0, '269702 No more task'
execute rdt.rdtAddMsg 269703, 10, '269703UpdTaskDtlFail',   'us_english', 1764, 0, '269703 Update taskdetail fail'

select * from rdt.rdtmsg(nolock) where message_id between 269701 and 269750
