-- rdt_840ExtUpd08
execute rdt.rdtDropMsg 146151 , 146200

execute rdt.rdtAddMsg 146151, 10, '46151^UPD HOLD FAIL',     'us_english', 840
execute rdt.rdtAddMsg 146152, 10, '46152^PACKCFM FAIL',      'us_english', 840
execute rdt.rdtAddMsg 146153, 10, '46153^UPD SOStat ERR',    'us_english', 840

--WMS-12877
execute rdt.rdtAddMsg 146154, 10, 'ORDERS SHORT PICK',       'us_english', 840

--WMS-20442
execute rdt.rdtAddMsg 146155, 10, '146155 GenTLog2 Fail',    'us_english', 840
execute rdt.rdtAddMsg 146156, 10, '146156 DelTLog2 Fail',    'us_english', 840

SELECT * FROM RDT.RDTMsg AS r (NOLOCK) WHERE r.Message_ID BETWEEN 146151 AND 146200