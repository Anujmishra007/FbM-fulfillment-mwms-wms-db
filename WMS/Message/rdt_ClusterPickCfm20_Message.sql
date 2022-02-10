--rdt_ClusterPickCfm20
execute rdt.rdtdropmsg 176251 , 176300

execute rdt.rdtAddMsg 176251, 10, '176251^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 176252, 10, '176252^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 176253, 10, '176253^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 176254, 10, '176254^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 176255, 10, '176255^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 176256, 10, '176256^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 176257, 10, '176257^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 176258, 10, '176258^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 176259, 10, '176259^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 176260, 10, '176260^GenLabelFail',   'us_english'
execute rdt.rdtAddMsg 176261, 10, '176261^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 176262, 10, '176262^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 176263, 10, '176263^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 176264, 10, '176264^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 176265, 10, '176265^Pack Cfm Fail',  'us_english'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 176251 AND 176300
