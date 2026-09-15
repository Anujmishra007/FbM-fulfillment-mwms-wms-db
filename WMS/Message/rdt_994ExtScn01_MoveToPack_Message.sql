--rdt_994ExtScn01_MoveToPack
--execute rdt.rdtdropmsg 281001, 281050
execute rdt.rdtDropMsg 281001, 281050

execute rdt.rdtAddMsg 281001, 10, '281001^InsPKDFail',          'us_english', 994, 0, '281001: Insert PickDetail failed'
execute rdt.rdtAddMsg 281002, 10, '281002^InsPKDFail',          'us_english', 994, 0, '281002: Insert PickDetail failed'
execute rdt.rdtAddMsg 281003, 10, '281003^InsUCCFail',          'us_english', 994, 0, '281003: Insert UCC failed'
execute rdt.rdtAddMsg 281004, 10, '281004^PickDetailNotFound',  'us_english', 994, 0, '281004: No PickDetail found for packing'
execute rdt.rdtAddMsg 281005, 10, '281005^InvalidSetup',        'us_english', 994, 0, '281005: Incorrect setup'
execute rdt.rdtAddMsg 281006, 10, '281006^InvalidSetup',        'us_english', 994, 0, '281006: Incorrect setup'
execute rdt.rdtAddMsg 281007, 10, '281007^InvalidSetup',        'us_english', 994, 0, '281007: Incorrect setup'
execute rdt.rdtAddMsg 281008, 10, '281008^DelMergeDupFail',     'us_english', 994, 0, '281008: Delete merge duplicates failed'
execute rdt.rdtAddMsg 281009, 10, '281009^UpdDropIDFail',       'us_english', 994, 0, '281009: Update DropID/Qty failed'
execute rdt.rdtAddMsg 281010, 10, '281010^UpdUCCStatusFail',    'us_english', 994, 0, '281010: Update UCC status failed'
execute rdt.rdtAddMsg 281011, 10, '281011^MergePKDFail',        'us_english', 994, 0, '281011: Merge PickDetail failed'


select * from rdt.rdtmsg (nolock) where message_id between 281001 and 281050
