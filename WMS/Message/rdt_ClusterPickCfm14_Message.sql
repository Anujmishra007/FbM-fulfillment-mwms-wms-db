-- rdt_ClusterPickCfm14
execute rdt.rdtdropmsg 138601 , 138650

execute rdt.rdtAddMsg 138601, 10, '38601^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 138602, 10, '38602^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 138603, 10, '38603^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 138604, 10, '38604^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 138605, 10, '38605^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 138606, 10, '38606^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 138607, 10, '38607^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 138608, 10, '38608^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 138609, 10, '38609^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 138610, 10, '38610^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 138611, 10, '38611^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 138612, 10, '38612^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 138613, 10, '38613^InsPackInfFail', 'us_english'
execute rdt.rdtAddMsg 138614, 10, '38614^UpdPackInfFail', 'us_english'
execute rdt.rdtAddMsg 138615, 10, '38615^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 138616, 10, '38615^No Pickslip',    'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 138601 AND 138650
