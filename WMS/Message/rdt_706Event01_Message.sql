-- rdt_706Event01
exec rdt.rdtdropmsg 139701, 139750

execute rdt.rdtAddMsg 139701, 10, '139701Bad EventCode ', 'us_english', 706
execute rdt.rdtAddMsg 139702, 10, '139702Bad Carrier   ', 'us_english', 706
execute rdt.rdtAddMsg 139703, 10, '139703Need pallet ID', 'us_english', 706
execute rdt.rdtAddMsg 139704, 10, '139704Need case ID  ', 'us_english', 706

--WMS10195
execute rdt.rdtAddMsg 139705, 10, '139705PD NoExists', 'us_english', 706
execute rdt.rdtAddMsg 139706, 10, '139706INS PLT FAIL', 'us_english', 706
execute rdt.rdtAddMsg 139707, 10, '139707INS PD FAIL', 'us_english', 706
execute rdt.rdtAddMsg 139708, 10, '139708Upd PLT FAIL', 'us_english', 706
execute rdt.rdtAddMsg 139709, 10, '139709Upd PD FAIL', 'us_english', 706
execute rdt.rdtAddMsg 139710, 10, '139710^PaperPrnterReq', 'us_english', 706
execute rdt.rdtAddMsg 139711, 10, '139711^DWNOTSetup', 'us_english', 706
execute rdt.rdtAddMsg 139712, 10, '139712^TgetDBNotSet', 'us_english', 706
execute rdt.rdtAddMsg 139713, 10, '139713^InvOption', 'us_english', 706
execute rdt.rdtAddMsg 139714, 10, '139714^InvOption', 'us_english', 706
execute rdt.rdtAddMsg 139715, 10, '139715^InvOption', 'us_english', 706
execute rdt.rdtAddMsg 139716, 10, '139716^InvOption', 'us_english', 706
execute rdt.rdtAddMsg 139717, 10, '139717^CaseIDExists', 'us_english', 706

--wms16561
execute rdt.rdtAddMsg 139718, 10, '139718InvalidCaseID', 'us_english', 706