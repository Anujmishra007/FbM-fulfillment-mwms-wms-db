--rdt_PickReallo01_Message.sql
-- 249301 - 249350
 
execute rdt.rdtDropMsg 249301, 249350	

execute rdt.rdtAddMsg 249301, 10, '249301^InvalidType',      'us_english', 1864, 0, '249301: Invalid Type'
execute rdt.rdtAddMsg 249302, 10, '249302^IDRequired',       'us_english', 1864, 0, '249302: ID Required'
execute rdt.rdtAddMsg 249303, 10, '249303^LocRequired',      'us_english', 1864, 0, '249303: Loc Required'
execute rdt.rdtAddMsg 249304, 10, '249304^PSNORequired',     'us_english', 1864, 0, '249304: PSNO Required'
execute rdt.rdtAddMsg 249305, 10, '249305^MultiSKU',         'us_english', 1864, 0, '249305: ID contain multi SKUs'
execute rdt.rdtAddMsg 249306, 10, '249306^NoRecordFound',    'us_english', 1864, 0, '249306: ID not found'
execute rdt.rdtAddMsg 249307, 10, '249307^NoLotFound',       'us_english', 1864, 0, '249307: No enough lot'
execute rdt.rdtAddMsg 249308, 10, '249308^GetPKDKeyFail',    'us_english', 1864, 0, '249308: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 249309, 10, '249309^GetPKDKeyFail',    'us_english', 1864, 0, '249309: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 249310, 10, '249310^UpdPKDFail',       'us_english', 1864, 0, '249310: Update PickDetail failed'
execute rdt.rdtAddMsg 249311, 10, '249311^MergePKDFail',     'us_english', 1864, 0, '249311: Merge to PickDetail failed'
execute rdt.rdtAddMsg 249312, 10, '249312^MergeRFKFail',     'us_english', 1864, 0, '249312: Merge to RefKeyLookup failed'
execute rdt.rdtAddMsg 249313, 10, '249313^DelPKDFail',       'us_english', 1864, 0, '249313: Failed to delete pickdetail'

select * from rdt.rdtmsg (nolock) where message_id between 249301 and 249350
