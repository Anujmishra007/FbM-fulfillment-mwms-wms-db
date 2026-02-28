--rdt_PickReallo02_Message.sql

execute rdt.rdtDropMsg 240001 , 240050

execute rdt.rdtAddMsg 240001, 10, '240001InvalidType',      'us_english', 957, 0, '240001: Invalid Type'
execute rdt.rdtAddMsg 240002, 10, '240002SKURequired',      'us_english', 957, 0, '240002: SKU Required'
execute rdt.rdtAddMsg 240003, 10, '240003PutAwayZoneRequired', 'us_english', 957, 0, '240003: PutAwayZone Required'
execute rdt.rdtAddMsg 240004, 10, '240004LocRequired',      'us_english', 957, 0, '240004: SKU Required'
execute rdt.rdtAddMsg 240005, 10, '240005PSNORequired',     'us_english', 957, 0, '240005: PSNO Required'
execute rdt.rdtAddMsg 240006, 10, '240006LotRequired',      'us_english', 957, 0, '240006: Lot Required'
execute rdt.rdtAddMsg 240007, 10, '240007NoRecordFound',    'us_english', 957, 0, '240007: Not short record found'
execute rdt.rdtAddMsg 240008, 10, '240008NoUCCFound',       'us_english', 957, 0, '240008: No enough UCC to reallocate'
execute rdt.rdtAddMsg 240009, 10, '240009UpdUCCFail',       'us_english', 957, 0, '240009: Update UCC failed'
execute rdt.rdtAddMsg 240010, 10, '240010UpdPKDFail',       'us_english', 957, 0, '240010: Update PickDetail failed'
execute rdt.rdtAddMsg 240011, 10, '240011UpdUCCFail',       'us_english', 957, 0, '240011: Update UCC failed'
execute rdt.rdtAddMsg 240012, 10, '240012UpdPKDFail',       'us_english', 957, 0, '240012: Update PickDetail failed'
execute rdt.rdtAddMsg 240013, 10, '240013NoLotFound',       'us_english', 957, 0, '240013: No enough lot'
execute rdt.rdtAddMsg 240014, 10, '240014GetPKDKeyFail',    'us_english', 957, 0, '240014: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 240015, 10, '240015UpdPKDFail',       'us_english', 957, 0, '240015: Update PickDetail failed'
execute rdt.rdtAddMsg 240016, 10, '240016MergePKDFail',     'us_english', 957, 0, '240016: Merge to PickDetail failed'
execute rdt.rdtAddMsg 240017, 10, '240017GetPKDKeyFail',    'us_english', 957, 0, '240017: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 240018, 10, '240018DropIDEmpty',      'us_english', 957, 0, '240018: Empty DropID in Pickdetail'
execute rdt.rdtAddMsg 240019, 10, '240019MergeRFKFail',     'us_english', 957, 0, '240019: Merge to RefKeyLookup failed'
execute rdt.rdtAddMsg 240020, 10, '240020MergeRFKFail',     'us_english', 957, 0, '240020: Merge to RefKeyLookup failed'

select * from rdt.rdtmsg (nolock) where message_id between 235651 and 235700
