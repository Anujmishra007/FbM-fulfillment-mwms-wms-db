--rdt_511ExtValid10
--FCR-2804
execute rdt.rdtdropmsg 235951 , 236000

execute rdt.rdtAddMsg 235951, 10, '235951 PendingPutaway',                 'us_english', 511, 0, '235951 PendingPutaway'
execute rdt.rdtAddMsg 235952, 10, '235952 LPNLOCKEDINRFPUTAWAY',           'us_english', 511, 0, '235952 LPNLOCKEDINRFPUTAWAY'
execute rdt.rdtAddMsg 235953, 10, '235953 OVER MAX PALLET',                'us_english', 511, 0, '235953 OVER MAX PALLET'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 235951 AND 236000
