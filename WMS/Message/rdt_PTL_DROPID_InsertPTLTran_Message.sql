
-- rdt_PTL_DROPID_InsertPTLTran 
exec rdt.rdtDropMsg 140801   , 140850

execute rdt.rdtAddMsg 140801 , 10, '40801^UpdDropIDFail',       'us_english', 1835
execute rdt.rdtAddMsg 140802 , 10, '40802^UpdPTLTranFail',       'us_english', 1835
execute rdt.rdtAddMsg 140803 , 10, '40803^UserIDInUsed',    'us_english', 1835
execute rdt.rdtAddMsg 140804 , 10, '40804^NoPackTask',   'us_english', 1835
execute rdt.rdtAddMsg 140805 , 10, '40805^Invdropid',   'us_english', 1835
execute rdt.rdtAddMsg 140806 , 10, '40806^WrongWave',   'us_english', 1835


select * from rdt.rdtmsg (nolock) where message_id between '140801' and '140850'
