--rdt_ClusterPickCfm08
execute rdt.rdtdropmsg 117951 , 118000

execute rdt.rdtAddMsg 117951, 10, '17951^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117952, 10, '17952^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117953, 10, '17953^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117954, 10, '17954^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 117955, 10, '17955^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 117956, 10, '17956^INS RefKeyFail', 'us_english'
execute rdt.rdtAddMsg 117957, 10, '17957^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117958, 10, '17958^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117959, 10, '17959^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 117960, 10, '17960^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 117961, 10, '17961^GenLabelFail',   'us_english'
execute rdt.rdtAddMsg 117962, 10, '17962^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 117963, 10, '17963^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 117964, 10, '17964^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 117965, 10, '17965^UpdCaseID Fail', 'us_english'
execute rdt.rdtAddMsg 117966, 10, '17966^UPDPKLockFail',  'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 117951 AND 118000
