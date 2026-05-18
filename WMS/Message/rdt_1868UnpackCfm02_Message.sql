-- 259601 - 259650 - UWP-48932 NYE018

execute rdt.rdtDropMsg 259601, 259650

execute rdt.rdtAddMsg 259601, 10, '259601^Data Invalid ',  'us_english', 1868, 0, '259601^SKU Or PickDetailKey Not Exists'
execute rdt.rdtAddMsg 259602, 10, '259602^PickDtlUpdFail ',  'us_english', 1868, 0, '259602^Pickdetail upd fail'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 259601 AND 259650