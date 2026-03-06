
-- rdt_1764CfmExtUpd08
--256301 - 256350

execute rdt.rdtDropMsg 256301  , 256350

execute rdt.rdtAddMsg 256301, 10, '256301 UpdPkdFail',      'us_english', 1764, 0, '256301 Update PickDetail Fail'
execute rdt.rdtAddMsg 256302, 10, '256302 PartialShort',    'us_english', 1764, 0, '256302 Not Support Partial Short'
execute rdt.rdtAddMsg 256303, 10, '256303 UpdLLIFail',      'us_english', 1764, 0, '256303 Update Inventory Fail'
execute rdt.rdtAddMsg 256304, 10, '256304 SKUEmpty',        'us_english', 1764
execute rdt.rdtAddMsg 256305, 10, '256305 UCCEmpty',        'us_english', 1764
execute rdt.rdtAddMsg 256306, 10, '256306 WaveEmpty',       'us_english', 1764 
execute rdt.rdtAddMsg 256307, 10, '256307 NoQcmdConfig',    'us_english', 1764 
execute rdt.rdtAddMsg 256308, 10, '256308 QcmdFail',        'us_english', 1764, 0, '256308 Create Qcmd task fail' 
execute rdt.rdtAddMsg 256309, 10, '256309 GenQcmdFail',     'us_english', 1764 
execute rdt.rdtAddMsg 256310, 10, '256310 InvSPName',       'us_english', 1764, 0, '256310 Invalid SP in Qcmd config' 
execute rdt.rdtAddMsg 256311, 10, '256311 UpdLLIFail',      'us_english', 1764, 0, '256311 Update Inventory Fail'
execute rdt.rdtAddMsg 256312, 10, '256312 UpdPkdFail',      'us_english', 1764, 0, '256312 Update PickDetail Fail'

select * from rdt.rdtmsg with (nolock) where message_id between 256301 and 256350