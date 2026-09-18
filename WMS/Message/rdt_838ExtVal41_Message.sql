--rdt_838ExtVal41
--execute rdt.rdtdropmsg 272301, 272350
execute rdt.rdtDropMsg 272301, 272350

execute rdt.rdtAddMsg 272301, 10, '272301SortPendiente',        'us_english', 838, 0, '272301: Sort Pendiente'
execute rdt.rdtAddMsg 272302, 10, '272302PickNotFound',         'us_english', 838, 0, '272302: PickDetail not found'
execute rdt.rdtAddMsg 272303, 10, '272303PickNotFinished',      'us_english', 838, 0, '272303: Picking not finished'
execute rdt.rdtAddMsg 272304, 10, '272304PTWLogNotFound',       'us_english', 838, 0, '272304: PTW log not found for DropID'
execute rdt.rdtAddMsg 272305, 10, '272305InvalidOpt',           'us_english', 838, 0, '272305: ECOM: Invalid option'
execute rdt.rdtAddMsg 272306, 10, '272306InvalidOpt',           'us_english', 838, 0, '272306: Invalid option'
execute rdt.rdtAddMsg 272307, 10, '272307Opt2NotAllowed',       'us_english', 838, 0, '272307: Option 2 not allowed'
execute rdt.rdtAddMsg 272308, 10, '272308PKDNotFound',          'us_english', 838, 0, '272308: Unpacked Pick detail not found'
execute rdt.rdtAddMsg 272309, 10, '272309ESC para cerrar',      'us_english', 838, 0, '272309: ESC para cerrar'
execute rdt.rdtAddMsg 272310, 10, '272310DropIDInMultiPSNO',    'us_english', 838, 0, '272310: FromDropID in Multi PSNO'
execute rdt.rdtAddMsg 272311, 10, '272311tPSNOInsError',        'us_english', 838, 0, '272311: Error inserting tPSNO'
execute rdt.rdtAddMsg 272312, 10, '272312tPSNOInsError',        'us_english', 838, 0, '272312: Error inserting tPSNO'
execute rdt.rdtAddMsg 272313, 10, '272313MultiPSNOError',       'us_english', 838, 0, '272313: FromDropID in Multi PSNO'
execute rdt.rdtAddMsg 272314, 10, '272314PackQty>PickQty',      'us_english', 838, 0, '272314: PackQty > PickQty'

select * from rdt.rdtmsg (nolock) where message_id between 272301 and 272350
