--rdt_ClusterPickCfm18
--execute rdt.rdtdropmsg 167251, 167300
execute rdt.rdtAddMsg 167251, 10, '67251^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 167252, 10, '67252^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 167253, 10, '67253^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 167254, 10, '67254^GetDetKeyFail',  'us_english'
execute rdt.rdtAddMsg 167255, 10, '67255^Ins PDtl Fail',  'us_english'
execute rdt.rdtAddMsg 167256, 10, '67256^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 167257, 10, '67257^OffSetPDtlFail', 'us_english'
execute rdt.rdtAddMsg 167258, 10, '67258^SKU OverPacked', 'us_english'
execute rdt.rdtAddMsg 167259, 10, '67259^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 167260, 10, '67260^GenLabelFail',   'us_english'
execute rdt.rdtAddMsg 167261, 10, '67261^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 167262, 10, '67262^InsPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 167263, 10, '67263^UpdPackDtlFail', 'us_english'
execute rdt.rdtAddMsg 167264, 10, '67264^UPDPKLockFail',  'us_english'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 167251 and 167300
