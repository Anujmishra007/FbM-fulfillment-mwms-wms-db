-- rdt_PackByTrackNo_PackCfm
execute rdt.rdtdropmsg 158851 , 158900

execute rdt.rdtAddMsg 158851, 10, '58851^GetRightFail',  'us_english', 840
execute rdt.rdtAddMsg 158852, 10, '58852^AutoMBOLPack',  'us_english', 840
execute rdt.rdtAddMsg 158853, 10, '58853^ConfPackFail',  'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 158851 AND 158900
