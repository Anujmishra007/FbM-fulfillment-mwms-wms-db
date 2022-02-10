-- isp_WS_WCS_VF_ContainerCommand (range 82401 - 82450)

-- delete from rdt.rdtMsg where message_id between 82401 and 82450
-- execute rdt.rdtDropMsg 82401, 82450

execute rdt.rdtAddMsg 82401, 10, '82401^INV WSCONFPATH', 'us_english'
execute rdt.rdtAddMsg 82402, 10, '82402^INV WS URL',     'us_english'
execute rdt.rdtAddMsg 82403, 10, '82403^INVALID LPNNO',  'us_english'
execute rdt.rdtAddMsg 82404, 10, '82404^INV CONTNRTYPE', 'us_english'
execute rdt.rdtAddMsg 82405, 10, '82405^TOLOC EMPTY',    'us_english'
execute rdt.rdtAddMsg 82406, 10, '82406^INSRT LOG FAIL', 'us_english'
execute rdt.rdtAddMsg 82407, 10, '82407^GETRIGHT FAIL',  'us_english'
execute rdt.rdtAddMsg 82408, 10, '82408^SEND WS FAIL',   'us_english'
execute rdt.rdtAddMsg 82409, 10, '82409^SEND WS FAIL',   'us_english'
execute rdt.rdtAddMsg 82410, 10, '82410^UPDT LOG FAIL',  'us_english'
execute rdt.rdtAddMsg 82411, 10, '82411^GETRIGHT FAIL',  'us_english'
execute rdt.rdtAddMsg 82412, 10, '82412^INSRT RT FAIL',  'us_english'
execute rdt.rdtAddMsg 82413, 10, '82413^LPNNO EMPTY',    'us_english'
execute rdt.rdtAddMsg 82414, 10, '82414^GETRIGHT FAIL',  'us_english'
execute rdt.rdtAddMsg 82415, 10, '82415^DBNAME EMPTY',   'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 82401 AND 82450