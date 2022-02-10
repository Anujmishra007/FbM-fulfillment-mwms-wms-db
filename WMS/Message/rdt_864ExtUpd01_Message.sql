--rdt_864ExtUpd01
execute rdt.rdtDropMsg 124951 , 125000

execute rdt.rdtAddMsg 124951, 10, '24951^No LoadKey',       'us_english', 864
execute rdt.rdtAddMsg 124952, 10, '24952^GetKey Fail',      'us_english', 864
execute rdt.rdtAddMsg 124953, 10, '24953^GenPKSlip Fail',   'us_english', 864
execute rdt.rdtAddMsg 124954, 10, '24954^Over Pack',        'us_english', 864
execute rdt.rdtAddMsg 124955, 10, '24955^InsPackHdrFail',   'us_english', 864
execute rdt.rdtAddMsg 124956, 10, '24956^InsPKInfoFail',    'us_english', 864
execute rdt.rdtAddMsg 124957, 10, '24957^GET LABEL Fail',   'us_english', 864
execute rdt.rdtAddMsg 124958, 10, '24958^InsPackDtlFail',   'us_english', 864
execute rdt.rdtAddMsg 124959, 10, '24959^InsPackDtlFail',   'us_english', 864
execute rdt.rdtAddMsg 124960, 10, '24960^UpdPackDtlFail',   'us_english', 864
execute rdt.rdtAddMsg 124961, 10, '24961^PackCfm Fail',     'us_english', 864
execute rdt.rdtAddMsg 124962, 10, '24962^PickCfm Fail',     'us_english', 864
execute rdt.rdtAddMsg 124963, 10, '24963^InsRefKey Fail',   'us_english', 864



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 124951 AND 125000