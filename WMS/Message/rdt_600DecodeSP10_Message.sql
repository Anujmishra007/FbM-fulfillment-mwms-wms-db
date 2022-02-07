-- rdt_600DecodeSP10
execute rdt.rdtDropMsg 176601, 176650

execute rdt.rdtAddMsg 176601, 10, '176601^ScanPlTSSCC  ', 'us_english', 600
execute rdt.rdtAddMsg 176602, 10, '176602^ScanCaseSSCC ', 'us_english', 600
execute rdt.rdtAddMsg 176603, 10, '176603^PltSSCCNotReq', 'us_english', 600
execute rdt.rdtAddMsg 176604, 10, '176604^PalletSSCCErr', 'us_english', 600
execute rdt.rdtAddMsg 176605, 10, '176605^ScanCaseSSCC ', 'us_english', 600
execute rdt.rdtAddMsg 176606, 10, '176606^CaseSSCCErr  ', 'us_english', 600
execute rdt.rdtAddMsg 176607, 10, '176607^CaseSSCCErr  ', 'us_english', 600
execute rdt.rdtAddMsg 176608, 10, '176608^PalletSSCCErr', 'us_english', 600


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 176601 AND 176650