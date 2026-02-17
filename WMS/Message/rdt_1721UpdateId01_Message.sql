
-- rdt_1721UpdateId01
-- UWP-39586 Performance tuning
EXECUTE rdt.rdtDropMsg 245151, 245200

EXECUTE rdt.rdtAddMsg 245151  ,10 ,'245151 UpdPalletDetailFail',     'us_english' ,1721  ,0 ,N'245151 Update PalletDetail Failed'
EXECUTE rdt.rdtAddMsg 245152  ,10 ,'245152 UpdLLIFail',              'us_english' ,1721  ,0 ,N'245152 Update LOTXLOCXID Failed'
EXECUTE rdt.rdtAddMsg 245153  ,10 ,'245153 UpdPickDetailFail',       'us_english' ,1721  ,0 ,N'245153 Update PickDetail Failed'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 245151 AND 245200

