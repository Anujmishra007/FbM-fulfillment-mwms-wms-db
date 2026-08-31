-- rdt_1812Confirm05
-- 277001 - 277050

execute rdt.rdtDropMsg 277001, 277050

execute rdt.rdtAddMsg 277001, 10, '277001^GetKeyFail',      'us_english', 1812, 0, '277001: Get TaskDetailKey Fails'
execute rdt.rdtAddMsg 277002, 10, '277002^InsTaskDetFail',  'us_english', 1812, 0, '277002: Insert TaskDetail Fails'
execute rdt.rdtAddMsg 277003, 10, '277003^UpdPkDtlFail',    'us_english', 1812, 0, '277003: Update PickDetail Fails'
execute rdt.rdtAddMsg 277004, 10, '277004^GetKeyFail',      'us_english', 1812, 0, '277004: Get PickDetailKey Fails'
execute rdt.rdtAddMsg 277005, 10, '277005^InsPkDtlFail',    'us_english', 1812, 0, '277005: Insert PickDetail Fails'
execute rdt.rdtAddMsg 277006, 10, '277006^UpdPkDtlFail',    'us_english', 1812, 0, '277006: Update PickDetail Fails'
execute rdt.rdtAddMsg 277007, 10, '277007^NotFullyOffset',  'us_english', 1812, 0, '277007: QTY Not Fully Offset'
execute rdt.rdtAddMsg 277008, 10, '277008^UpdTaskDetFail',  'us_english', 1812, 0, '277008: Update TaskDetail Fails'
execute rdt.rdtAddMsg 277009, 10, '277009^UpdPkDtlFail',    'us_english', 1812, 0, '277009: Update PickDetail Fails'
execute rdt.rdtAddMsg 277010, 10, '277010^DelFCPLogFail',   'us_english', 1812, 0, '277010: Delete FCPLog Fails'

select * from rdt.rdtmsg (nolock) where message_id between 277001 and 277050
