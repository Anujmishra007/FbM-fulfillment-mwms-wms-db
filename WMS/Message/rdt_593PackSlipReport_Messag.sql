--rdt_593PackSlipReport
--FCR-1096
execute rdt.rdtDropMsg 227951 , 228000

execute rdt.rdtAddMsg 227951, 10, '227951OrderKeyNeeded',         'us_english'
execute rdt.rdtAddMsg 227952, 10, '227952PackNotDone',            'us_english'
execute rdt.rdtAddMsg 227953, 10, '227953MPOC Order',             'us_english'
execute rdt.rdtAddMsg 227954, 10, '227954InvOLPSCode',            'us_english'
execute rdt.rdtAddMsg 227955, 10, '227955InvalidOrder',           'us_english'
execute rdt.rdtAddMsg 227956, 10, '227956PickNotStart',           'us_english'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 227951 AND 228000