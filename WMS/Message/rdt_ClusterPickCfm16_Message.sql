--rdt_ClusterPickCfm16
rdt.rdtDropMsg 169001 , 169050	

execute rdt.rdtAddMsg 169001, 10, '169001OffSetPDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169002, 10, '169002OffSetPDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169003, 10, '169003OffSetPDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169004, 10, '169004 GetDetKeyFail',  'us_english', 1628
execute rdt.rdtAddMsg 169005, 10, '169005 Ins PDtl Fail',  'us_english', 1628
execute rdt.rdtAddMsg 169006, 10, '169006INS RefKeyFail',  'us_english', 1628
execute rdt.rdtAddMsg 169007, 10, '169007OffSetPDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169008, 10, '169008OffSetPDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169009, 10, '169009SKU Overpacked',  'us_english', 1628
execute rdt.rdtAddMsg 169010, 10, '169010 InsPHdrFail',    'us_english', 1628
execute rdt.rdtAddMsg 169011, 10, '169011InsPackDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169012, 10, '169012InsPackDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169013, 10, '169013InsPackDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169014, 10, '169014UpdPackDtlFail',  'us_english', 1628
execute rdt.rdtAddMsg 169015, 10, '169015UpdCaseID Fail',  'us_english', 1628
execute rdt.rdtAddMsg 169016, 10, '169016UpdCaseID Fail',  'us_english', 1628
execute rdt.rdtAddMsg 169017, 10, '169017UpdCaseID Fail',  'us_english', 1628
execute rdt.rdtAddMsg 169018, 10, '169018UpdCaseID Fail',  'us_english', 1628
execute rdt.rdtAddMsg 169019, 10, '169019 UPD UCC Fail',   'us_english', 1628
execute rdt.rdtAddMsg 169020, 10, '169020UPDPKLockFail',   'us_english', 1628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 169001 AND 169050
