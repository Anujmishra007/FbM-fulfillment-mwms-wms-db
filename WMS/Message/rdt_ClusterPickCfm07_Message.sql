--rdt_ClusterPickCfm07
execute rdt.rdtdropmsg 112701 , 112750

execute rdt.rdtAddMsg 112701, 10, '12701^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 112702, 10, '12702^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 112703, 10, '12703^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 112704, 10, '12704^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 112705, 10, '12705^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 112706, 10, '12706^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 112707, 10, '12707^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 112708, 10, '12708^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 112709, 10, '12709^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 112710, 10, '12710^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 112711, 10, '12711^Casecnt = 0',    'us_english'
execute rdt.rdtAddMsg 112712, 10, '12712^UpdCaseID Fail', 'us_english'
execute rdt.rdtAddMsg 112713, 10, '12713^Gen Label Fail', 'us_english'
execute rdt.rdtAddMsg 112714, 10, '12714^InsPackinfFail', 'us_english'
execute rdt.rdtAddMsg 112715, 10, '12715^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 112716, 10, '12716^InsPackinfFail', 'us_english'
execute rdt.rdtAddMsg 112717, 10, '12717^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 112718, 10, '12718^No Pack Record', 'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112701 AND 112750