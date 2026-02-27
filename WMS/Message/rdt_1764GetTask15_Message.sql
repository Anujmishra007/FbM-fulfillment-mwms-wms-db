--rdt_1764GetTask15
--252601 - 252650

execute rdt.rdtdropmsg 252601, 252650

execute rdt.rdtAddMsg 252601, 10, '252601Exceed Max Ctn',   'us_english', 1764, 0, '252601 Exceed Max Ctn'
execute rdt.rdtAddMsg 252602, 10, '252602CasePickDone',     'us_english', 1764, 0, '252602 Case Pick Done'
execute rdt.rdtAddMsg 252603, 10, '252603No more task  ',   'us_english', 1764, 0, '252603 No more task'
execute rdt.rdtAddMsg 252604, 10, '252604UpdTaskDtlFail',   'us_english', 1764, 0, '252604 Update taskdetail fail'
execute rdt.rdtAddMsg 252605, 10, '252605NoGrpKey',         'us_english', 1764, 0, '252605 GroupKey is empty. Close pallet.'
execute rdt.rdtAddMsg 252606, 10, '252606UpdTaskDtlFail',   'us_english', 1764, 0, '252606 Update taskdetail fail'
execute rdt.rdtAddMsg 252607, 10, '252607BookLocFail',      'us_english', 1764, 0, '252607 Book Loc fail'


select * from rdt.rdtmsg(nolock) where message_id between 252601 and 252650