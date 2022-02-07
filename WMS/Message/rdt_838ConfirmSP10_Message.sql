-- rdt_838ConfirmSP10
execute rdt.rdtDropMsg 179451, 179500

execute rdt.rdtAddMsg 179451, 10, '179451InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 179452, 10, '179452GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 179453, 10, '179453GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 179454, 10, '179454InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 179455, 10, '179455UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 179456, 10, '179456INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 179457, 10, '179457UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 179458, 10, '179458UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 179459, 10, '179459SN QTYNotTally', 'us_english', 838
execute rdt.rdtAddMsg 179460, 10, '179460INSPackSNOFail', 'us_english', 838
execute rdt.rdtAddMsg 179461, 10, '179461SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 179462, 10, '179462DEL TmpSN Fail', 'us_english', 838
execute rdt.rdtAddMsg 179463, 10, '179463Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 179464, 10, '179464Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 179465, 10, '179465INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 179466, 10, '179466SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 179467, 10, '179467INS PDInfoFail', 'us_english', 838
execute rdt.rdtAddMsg 179468, 10, '179468UPD PDInfoFail', 'us_english', 838

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN  179451 AND 179500
 

