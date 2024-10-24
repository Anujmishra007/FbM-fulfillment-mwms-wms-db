-- rdt_Pack_LVSUSA_Confirm
execute rdt.rdtDropMsg 227601, 227650

execute rdt.rdtAddMsg 227601, 10, '227601InvalidType', 'us_english', 993, 0 , '227601 Invalid Type'
execute rdt.rdtAddMsg 227602, 10, '227602SKUNotInOriCart', 'us_english', 993, 0 , '227602 SKU Not In Orignal Carton'
execute rdt.rdtAddMsg 227603, 10, '227603GenLabelNoFail', 'us_english', 993, 0 , '227603 Generate Label No Failure'
execute rdt.rdtAddMsg 227604, 10, '227604UpdPackDetailFail', 'us_english', 993, 0 , '227604 PackDetail Update Failure'
execute rdt.rdtAddMsg 227605, 10, '227605DelPackDetailFail', 'us_english', 993, 0 , '227605 Delete PackDetail Fail'
execute rdt.rdtAddMsg 227606, 10, '227606InsPackDetailFail', 'us_english', 993, 0 , '227606 Insert PackDetail Fail'
execute rdt.rdtAddMsg 227607, 10, '227607InsPackDetailFail', 'us_english', 993, 0 , '227607 Insert PackInfo Fail'
execute rdt.rdtAddMsg 227608, 10, '227608UpdPackDetailFail', 'us_english', 993, 0 , '227608 PackDetail Update Failure'
execute rdt.rdtAddMsg 227609, 10, '227609InsPackDetailFail', 'us_english', 993, 0 , '227609 Insert PackDetail Fail'
execute rdt.rdtAddMsg 227610, 10, '227610InsMoveLogFail', 'us_english', 993, 0 , '227610 Fail to Insert MoveLog'


select * from rdt.rdtmsg (nolock) where message_id between 227601 AND 227650

/*
execute rdt.rdtAddMsg 100401, 10, '100401InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 100402, 10, '100402GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 100403, 10, '100403GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 100404, 10, '100404InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 100405, 10, '100405UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 100406, 10, '100406INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 100407, 10, '100407UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 100408, 10, '100408UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 100409, 10, '100409SN QTYNotTally', 'us_english', 838
execute rdt.rdtAddMsg 100410, 10, '100410INSPackSNOFail', 'us_english', 838
execute rdt.rdtAddMsg 100411, 10, '100411SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 100412, 10, '100412DEL TmpSN Fail', 'us_english', 838
execute rdt.rdtAddMsg 100413, 10, '100413Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 100414, 10, '100414Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 100415, 10, '100415INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 100416, 10, '100416SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 100417, 10, '100417INS PDInfoFail', 'us_english', 838
execute rdt.rdtAddMsg 100418, 10, '100418UPD PDInfoFail', 'us_english', 838
*/