--rdt_ScanPalletToMBOL_Confirm
rdt.rdtDropMsg 141701 , 141750

execute rdt.rdtAddMsg 141701, 10, '41701^INS MBDtl Fail',     'us_english', 1666

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141701 AND 141750