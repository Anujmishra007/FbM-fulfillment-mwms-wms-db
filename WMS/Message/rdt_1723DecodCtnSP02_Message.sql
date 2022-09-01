-- rdt_1723DecodCtnSP02
execute rdt.rdtdropmsg 176801, 176850

execute rdt.rdtAddMsg 176801, 10, '176801^CaseSSCCErr  ',    'us_english', 1723
execute rdt.rdtAddMsg 176802, 10, '176802^SSCC NotMatch',    'us_english', 1723
execute rdt.rdtAddMsg 176803, 10, '176803^Invalid SSCC ',    'us_english', 1723
execute rdt.rdtAddMsg 176804, 10, '176804^Invalid SSCC ',    'us_english', 1723
execute rdt.rdtAddMsg 176805, 10, '176805^Invalid SSCC ',    'us_english', 1723
execute rdt.rdtAddMsg 176806, 10, '176806^Invalid SSCC ',    'us_english', 1723

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 176801 AND 176850

