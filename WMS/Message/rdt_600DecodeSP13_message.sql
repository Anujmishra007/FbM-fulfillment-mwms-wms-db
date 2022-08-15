-- rdt_600DecodeSP13
execute rdt.rdtDropMsg 189651, 189700

execute rdt.rdtAddMsg 189651, 10, '189651^ScanPlTSSCC  ', 'us_english', 600
execute rdt.rdtAddMsg 189652, 10, '189652^ScanCaseSSCC ', 'us_english', 600
execute rdt.rdtAddMsg 189653, 10, '189653^PltSSCCNotReq', 'us_english', 600
execute rdt.rdtAddMsg 189654, 10, '189654^PalletSSCCErr', 'us_english', 600
execute rdt.rdtAddMsg 189655, 10, '189655^ScanCaseSSCC ', 'us_english', 600
execute rdt.rdtAddMsg 189656, 10, '189656^CaseSSCCErr  ', 'us_english', 600
execute rdt.rdtAddMsg 189657, 10, '189657^CaseSSCCErr  ', 'us_english', 600
execute rdt.rdtAddMsg 189658, 10, '189658^PalletSSCCErr', 'us_english', 600


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 189651 AND 189700