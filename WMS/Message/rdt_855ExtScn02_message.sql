--rdt_855ExtScn02
--242301 - 242350

rdt.rdtDropMsg 242301, 242350

execute rdt.rdtAddMsg 242301, 10, '242301^LoadKeyRequired',     'us_english', 855, 0, '242301 LoadKey is required'
execute rdt.rdtAddMsg 242302, 10, '242302^InvalidLoadkey ',     'us_english', 855, 0, '242302 Invalid Loadkey'
execute rdt.rdtAddMsg 242303, 10, '242303^NoPickDetail',        'us_english', 855, 0, '242303 No valid pickdetail found'
execute rdt.rdtAddMsg 242304, 10, '242304^InvalidDropID',       'us_english', 855, 0, '242304 Invalid drop id'
execute rdt.rdtAddMsg 242305, 10, '242305^Not Scan-in   ',      'us_english', 855
execute rdt.rdtAddMsg 242306, 10, '242306^Not Scan-out  ',      'us_english', 855
execute rdt.rdtAddMsg 242307, 10, '242307^OptRequired',         'us_english', 855, 0, '242307 Option is required'
execute rdt.rdtAddMsg 242308, 10, '242308^InvalidOption',       'us_english', 855, 0, '242308 Invalid option'
execute rdt.rdtAddMsg 242309, 10, '242309^ReasonRequired',      'us_english', 855, 0, '242309 Reason is required'



SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 242301 AND 242350