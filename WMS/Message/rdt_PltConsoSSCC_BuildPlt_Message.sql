--rdt_PltConsoSSCC_BuildPlt
execute rdt.rdtdropmsg 98351 , 98400

execute rdt.rdtAddMsg 98351, 10, '98351^SSCC REQ',       'us_english', 1723
execute rdt.rdtAddMsg 98352, 10, '98352^INS PLT FAIL',   'us_english', 1723
execute rdt.rdtAddMsg 98353, 10, '98353^INS PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98354, 10, '98354^UPD PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98355, 10, '98355^GEN SSCC# FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98356, 10, '98356^INS PLT FAIL',   'us_english', 1723
execute rdt.rdtAddMsg 98357, 10, '98357^INS PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98358, 10, '98358^UPD PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98359, 10, '98359^GEN SSCC# FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98360, 10, '98360^INS PLT FAIL',   'us_english', 1723
execute rdt.rdtAddMsg 98361, 10, '98361^INS PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98362, 10, '98362^UPD PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98363, 10, '98363^Get RFKey Fail', 'us_english', 1723
execute rdt.rdtAddMsg 98364, 10, '98364^OffSetPDtlFail', 'us_english', 1723
execute rdt.rdtAddMsg 98365, 10, '98365^GetDetKeyFail',  'us_english', 1723
execute rdt.rdtAddMsg 98366, 10, '98366^Ins PDtl Fail',  'us_english', 1723
execute rdt.rdtAddMsg 98367, 10, '98367^OffSetPDtlFail', 'us_english', 1723
execute rdt.rdtAddMsg 98368, 10, '98368^UPD PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98369, 10, '98369^UPD PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98370, 10, '98370^REL PDTL FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 98371, 10, '98371^INS LOG FAIL',   'us_english', 1723
execute rdt.rdtAddMsg 98372, 10, '98372^UPD LOG FAIL',   'us_english', 1723
execute rdt.rdtAddMsg 98373, 10, '98373^INS PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98374, 10, '98374^INS PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98375, 10, '98375^PLT CONSOLED',   'us_english', 1723
execute rdt.rdtAddMsg 98376, 10, '98376^GET SSCC FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 98377, 10, '98377^GET SSCC FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 98378, 10, '98378^GET SSCC FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 98379, 10, '98379^UPD PLTDT FAIL', 'us_english', 1723
execute rdt.rdtAddMsg 98380, 10, '98380^PLT CONSOLED',   'us_english', 1723

select * from rdt.rdtmsg (nolock) where message_id between 98351 and 98400