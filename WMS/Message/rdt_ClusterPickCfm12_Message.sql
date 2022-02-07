--rdt_ClusterPickCfm12
execute rdt.rdtdropmsg 131951 , 132000

execute rdt.rdtAddMsg 131951, 10, '131951^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 131952, 10, '131952^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 131953, 10, '131953^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 131954, 10, '131954^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 131955, 10, '131955^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 131956, 10, '131956^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 131957, 10, '131957^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 131958, 10, '131958^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 131959, 10, '131959^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 131960, 10, '131960^GenLabelFail',   'us_english'
execute rdt.rdtAddMsg 131961, 10, '131961^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 131962, 10, '131962^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 131963, 10, '131963^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 131964, 10, '131964^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 131965, 10, '131965^Scan In Fail',   'us_english'
execute rdt.rdtAddMsg 131966, 10, '131966^Scan In Fail',   'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 131951 AND 132000