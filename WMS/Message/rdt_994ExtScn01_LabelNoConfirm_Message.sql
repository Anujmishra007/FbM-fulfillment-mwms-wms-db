--rdt_994ExtScn01_LabelNoConfirm
--execute rdt.rdtdropmsg 281251, 281300
execute rdt.rdtDropMsg 281251, 281300

execute rdt.rdtAddMsg 281251, 10, '281251^MarshallingLaneNotFound', 'us_english', 994, 0, '281251: Marshalling lane not found'
execute rdt.rdtAddMsg 281252, 10, '281252^IncorrectSetup',          'us_english', 994, 0, '281252: Incorrect setup (MoveQTYAlloc/MoveQTYPick)'
execute rdt.rdtAddMsg 281253, 10, '281253^IncorrectSetup',          'us_english', 994, 0, '281253: Incorrect setup (MoveQTYAlloc with picked status)'
execute rdt.rdtAddMsg 281254, 10, '281254^IncorrectSetup',          'us_english', 994, 0, '281254: Incorrect setup (MoveQTYPick with alloc status)'
execute rdt.rdtAddMsg 281255, 10, '281255^InsMoveListFail',         'us_english', 994, 0, '281255: Insert move list failed'
execute rdt.rdtAddMsg 281256, 10, '281256^GenTransLogFail',         'us_english', 994, 0, '281256: Generate transmit log failed'
execute rdt.rdtAddMsg 281257, 10, '281257^InvMarshalling',          'us_english', 994, 0, '281257: Invalid Marshalling lane'
execute rdt.rdtAddMsg 281258, 10, '281258^InsPKDFailed',            'us_english', 994, 0, '281258: Insert pick detail failed'
execute rdt.rdtAddMsg 281259, 10, '281259^UpdPKDFailed',            'us_english', 994, 0, '281259: Update pick detail failed'
execute rdt.rdtAddMsg 281260, 10, '281260^GenTransLogFail',         'us_english', 994, 0, '281260: Generate ECOM transmit log failed (WSAEOSHIPLBL)'
execute rdt.rdtAddMsg 281261, 10, '281261^OrderNotFound',           'us_english', 994, 0, '281261: OrderKey not found in PackHeader'
execute rdt.rdtAddMsg 281262, 10, '281262^InstPDFailed',            'us_english', 994, 0, '281262: Insert @tPD failed'
execute rdt.rdtAddMsg 281263, 10, '281263^InstPDFailed',            'us_english', 994, 0, '281263: Insert @tPD failed'
execute rdt.rdtAddMsg 281264, 10, '281264^MergePKDFailed',          'us_english', 994, 0, '281264: Merge pick detail failed'

select * from rdt.rdtmsg (nolock) where message_id between 281251 and 281300
