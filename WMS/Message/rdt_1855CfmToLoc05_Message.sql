
-- rdt_1855CfmToLoc05
--262901 - 262950

execute rdt.rdtDropMsg 262901, 262950

execute rdt.rdtAddMsg 262901, 10, '262901 UPDTskDtlfail',     'us_english', 1855, 0, '262901 UPD TskDtl fail'
execute rdt.rdtAddMsg 262902, 10, '262902 UPDPKDtlFail',  'us_english', 1855, 0, '262902 UPD PKDtl Fail'

select * from rdt.rdtmsg (nolock) where message_id between '262901' and '262950'

