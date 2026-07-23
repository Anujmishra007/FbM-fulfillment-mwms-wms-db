--rdt_838ExtScn10_LabelNoConfirm
--execute rdt.rdtdropmsg 272701, 272750
execute rdt.rdtDropMsg 272701, 272750

execute rdt.rdtAddMsg 272701, 10, '272701^MarshallingLaneNotFound', 'us_english', 838, 0, '272701: Marshalling lane not found'
execute rdt.rdtAddMsg 272702, 10, '272702^IncorrectSetup',          'us_english', 838, 0, '272702: Incorrect setup (MoveQTYAlloc/MoveQTYPick)'
execute rdt.rdtAddMsg 272703, 10, '272703^IncorrectSetup',          'us_english', 838, 0, '272703: Incorrect setup (MoveQTYAlloc with picked status)'
execute rdt.rdtAddMsg 272704, 10, '272704^IncorrectSetup',          'us_english', 838, 0, '272704: Incorrect setup (MoveQTYPick with alloc status)'
execute rdt.rdtAddMsg 272705, 10, '272705^InsMoveListFail',         'us_english', 838, 0, '272705: Insert move list failed'
execute rdt.rdtAddMsg 272706, 10, '272706^GenTransLogFail',         'us_english', 838, 0, '272706: Generate transmit log failed'
execute rdt.rdtAddMsg 272707, 10, '272707^InvMarshalling',          'us_english', 838, 0, '272707: Invalid Marshalling lane'
execute rdt.rdtAddMsg 272708, 10, '272708^InsPKDFailed',            'us_english', 838, 0, '272708: Insert pick detail failed'
execute rdt.rdtAddMsg 272709, 10, '272709^UpdPKDFailed',            'us_english', 838, 0, '272709: Update pick detail failed'
execute rdt.rdtAddMsg 272710, 10, '272710^GenTransLogFail',         'us_english', 838, 0, '272710: Generate ECOM transmit log failed (WSAEOSHIPLBL)'
execute rdt.rdtAddMsg 272711, 10, '272711^OrderNotFound',           'us_english', 838, 0, '272711: OrderKey not found'

select * from rdt.rdtmsg (nolock) where message_id between 272701 and 272750
