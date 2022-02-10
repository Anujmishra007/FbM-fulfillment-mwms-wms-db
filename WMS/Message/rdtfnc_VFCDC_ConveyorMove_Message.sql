--rdtfnc_VFCDC_ConveyorMove
--execute rdt.rdtdropmsg 82451, 82500

execute rdt.rdtAddMsg 82451, 10, '82451^TOLOC REQ',      'us_english'
execute rdt.rdtAddMsg 82452, 10, '82452^INV TOLOC',      'us_english'
execute rdt.rdtAddMsg 82453, 10, '82453^LPNNO REQ',      'us_english'
execute rdt.rdtAddMsg 82454, 10, '82454^MAX 7 CARTON',   'us_english'
execute rdt.rdtAddMsg 82455, 10, '82455^Option Req',     'us_english'
execute rdt.rdtAddMsg 82456, 10, '82456^Invalid Opt',    'us_english'
execute rdt.rdtAddMsg 82457, 10, '82457^CrtRouteFailed', 'us_english'
execute rdt.rdtAddMsg 82458, 10, '82458^LPNNO REPEAT',   'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 82451 AND 82500