--rdt_ClusterPickCfm09
execute rdt.rdtdropmsg 117651 , 117700

execute rdt.rdtAddMsg 117651, 10, '17651^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117652, 10, '17652^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117653, 10, '17653^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117654, 10, '17654^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 117655, 10, '17655^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 117655, 10, '17655^INS RefKeyFail',  'us_english'
execute rdt.rdtAddMsg 117657, 10, '17657^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117658, 10, '17658^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 117659, 10, '17659^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 117660, 10, '17660^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 117661, 10, '17661^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 117662, 10, '17662^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 117663, 10, '17663^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 117664, 10, '17664^UpdCaseID Fail', 'us_english'
execute rdt.rdtAddMsg 117665, 10, '17665^UPDPKLockFail',  'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 117651 AND 117700
