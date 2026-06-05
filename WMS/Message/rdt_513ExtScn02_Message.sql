--rdt_513ExtScn02

execute rdt.rdtDropMsg 268651, 268700

execute rdt.rdtAddMsg 268651 ,10, '268651^TypeRequired',        'us_english', 513, 0, '268651: Pallet Type is required'
execute rdt.rdtAddMsg 268652 ,10, '268652^InvalidType',         'us_english', 513, 0, '268652: Invalid Pallet Type'
execute rdt.rdtAddMsg 268653 ,10, '268653^UpdMobrecFail',       'us_english', 513, 0, '268653: Update MOBREC failed'
execute rdt.rdtAddMsg 268654 ,10, '268654^UpdMobrecFail',       'us_english', 513, 0, '268654: Update MOBREC failed'


select * from rdt.rdtmsg (nolock) where message_id between 268651 and 268700
