
--rdt_KIT_Update_Confirm
--259001 - 259050


exec rdt.rdtdropmsg 259001 , 259050

execute rdt.rdtAddMsg 259001, 10, '259001^KITDtlNotFound',    'us_english', 1877, 0, '259001: KITDetail Not Found'
execute rdt.rdtAddMsg 259002, 10, '259002^UpdKITDtlFail',     'us_english', 1877, 0, '259002: Update KITDetail fail'


select * from rdt.rdtmsg (nolock) where message_id between 259001 AND 259050