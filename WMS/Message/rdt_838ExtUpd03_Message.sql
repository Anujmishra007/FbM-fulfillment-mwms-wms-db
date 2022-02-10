-- rdt_838ExtUpd03
execute rdt.rdtDropMsg 130401 , 130450

execute rdt.rdtAddMsg 130401, 10, '30401^UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 130402, 10, '30402^Ins PKInf Fail', 'us_english', 838
execute rdt.rdtAddMsg 130403, 10, '30403^Upd PKInf Fail', 'us_english', 838
execute rdt.rdtAddMsg 130404, 10, '30404^UpdPackUPCFail', 'us_english', 838
execute rdt.rdtAddMsg 130405, 10, '30405^UpdPackHdrFail', 'us_english', 838
execute rdt.rdtAddMsg 130406, 10, '30406^Upd PKInf Fail', 'us_english', 838

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130401 AND 130450
