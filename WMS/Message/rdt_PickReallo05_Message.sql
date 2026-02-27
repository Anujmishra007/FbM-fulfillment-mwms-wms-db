--rdt_PickReallo05_Message.sql
-- 258201 - 258250

 
execute rdt.rdtDropMsg 258201, 258250	

execute rdt.rdtAddMsg 258201, 10, '258201InvalidType',      'us_english', 839, 0, '258201: Invalid Type'
execute rdt.rdtAddMsg 258202, 10, '258202SKURequired',      'us_english', 839, 0, '258202: SKU Required'
execute rdt.rdtAddMsg 258203, 10, '258203PickZoneRequired', 'us_english', 839, 0, '258203: PickZone Required'
execute rdt.rdtAddMsg 258204, 10, '258204LocRequired',      'us_english', 839, 0, '258204: SKU Required'
execute rdt.rdtAddMsg 258205, 10, '258205PSNORequired',     'us_english', 839, 0, '258205: PSNO Required'
execute rdt.rdtAddMsg 258206, 10, '258206LotRequired',      'us_english', 839, 0, '258206: Lot Required'
execute rdt.rdtAddMsg 258207, 10, '258207NoRecordFound',    'us_english', 839, 0, '258207: Not short record found'
--execute rdt.rdtAddMsg 258208, 10, '258208NoUCCFound',       'us_english', 839, 0, '258208: No enough UCC to reallocate'
--execute rdt.rdtAddMsg 258209, 10, '258209UpdUCCFail',       'us_english', 839, 0, '258209: Update UCC failed'
--execute rdt.rdtAddMsg 258210, 10, '258210UpdPKDFail',       'us_english', 839, 0, '258210: Update PickDetail failed'
--execute rdt.rdtAddMsg 258211, 10, '258211UpdUCCFail',       'us_english', 839, 0, '258211: Update UCC failed'
--execute rdt.rdtAddMsg 258212, 10, '258212UpdPKDFail',       'us_english', 839, 0, '258212: Update PickDetail failed'
execute rdt.rdtAddMsg 258213, 10, '258213NoLotFound',       'us_english', 839, 0, '258213: No enough lot'
execute rdt.rdtAddMsg 258214, 10, '258214GetPKDKeyFail',    'us_english', 839, 0, '258214: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 258215, 10, '258215UpdPKDFail',       'us_english', 839, 0, '258215: Update PickDetail failed'
execute rdt.rdtAddMsg 258216, 10, '258216MergePKDFail',     'us_english', 839, 0, '258216: Merge to PickDetail failed'
execute rdt.rdtAddMsg 258217, 10, '258217GetPKDKeyFail',    'us_english', 839, 0, '258217: Generate PickDetailKey failed'
--execute rdt.rdtAddMsg 258218, 10, '258218DropIDEmpty',      'us_english', 839, 0, '258218: Empty DropID in Pickdetail'
execute rdt.rdtAddMsg 258219, 10, '258219MergeRFKFail',     'us_english', 839, 0, '258219: Merge to RefKeyLookup failed'

select * from rdt.rdtmsg (nolock) where message_id between 258201 and 258250
