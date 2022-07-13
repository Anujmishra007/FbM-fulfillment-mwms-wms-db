--rdt_838DecodeSN02
execute rdt.rdtdropmsg 148801 , 148850

execute rdt.rdtAddMsg 148801, 10, '48801^SrCnt NotMatch', 'us_english', 838
execute rdt.rdtAddMsg 148802, 10, '48802^SrCnt NotMatch', 'us_english', 838

-- WMS-19856
execute rdt.rdtAddMsg 148803, 10, '48803^Invalid Format', 'us_english', 838
execute rdt.rdtAddMsg 148804, 10, '48804^Invalid Format', 'us_english', 838

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 148801 AND 148850	