--rdt_PickReallo01_Message.sql
-- 235651 - 235700
 
execute rdt.rdtDropMsg 235651, 235700	

execute rdt.rdtAddMsg 235651, 10, '235651InvalidType',      'us_english', 957, 0, '235651: Invalid Type'
execute rdt.rdtAddMsg 235652, 10, '235652SKURequired',      'us_english', 957, 0, '235652: SKU Required'
execute rdt.rdtAddMsg 235653, 10, '235653PickZoneRequired', 'us_english', 957, 0, '235653: PickZone Required'
execute rdt.rdtAddMsg 235654, 10, '235654LocRequired',      'us_english', 957, 0, '235654: SKU Required'
execute rdt.rdtAddMsg 235655, 10, '235655PSNORequired',     'us_english', 957, 0, '235655: PSNO Required'
execute rdt.rdtAddMsg 235656, 10, '235656LotRequired',      'us_english', 957, 0, '235656: Lot Required'
execute rdt.rdtAddMsg 235657, 10, '235657NoRecordFound',    'us_english', 957, 0, '235657: Not short record found'
execute rdt.rdtAddMsg 235658, 10, '235658NoUCCFound',       'us_english', 957, 0, '235658: No enough UCC to reallocate'
execute rdt.rdtAddMsg 235659, 10, '235659UpdUCCFail',       'us_english', 957, 0, '235659: Update UCC failed'
execute rdt.rdtAddMsg 235660, 10, '235660UpdPKDFail',       'us_english', 957, 0, '235660: Update PickDetail failed'
execute rdt.rdtAddMsg 235661, 10, '235661UpdUCCFail',       'us_english', 957, 0, '235661: Update UCC failed'
execute rdt.rdtAddMsg 235662, 10, '235662UpdPKDFail',       'us_english', 957, 0, '235662: Update PickDetail failed'
execute rdt.rdtAddMsg 235663, 10, '235663NoLotFound',       'us_english', 957, 0, '235663: No enough lot'
execute rdt.rdtAddMsg 235664, 10, '235664GetPKDKeyFail',    'us_english', 957, 0, '235664: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 235665, 10, '235665UpdPKDFail',       'us_english', 957, 0, '235665: Update PickDetail failed'
execute rdt.rdtAddMsg 235666, 10, '235665MergePKDFail',     'us_english', 957, 0, '235666: Merge to PickDetail failed'
execute rdt.rdtAddMsg 235667, 10, '235667GetPKDKeyFail',    'us_english', 957, 0, '235667: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 235668, 10, '235668DropIDEmpty',      'us_english', 957, 0, '235668: Empty DropID in Pickdetail'
execute rdt.rdtAddMsg 235669, 10, '235669MergeRFKFail',     'us_english', 957, 0, '235669: Merge to RefKeyLookup failed'
execute rdt.rdtAddMsg 235670, 10, '235670MergeRFKFail',     'us_english', 957, 0, '235670: Merge to RefKeyLookup failed'

select * from rdt.rdtmsg (nolock) where message_id between 235651 and 235700
