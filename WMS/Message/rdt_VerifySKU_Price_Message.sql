-- rdt_VerifySKU_Price
execute rdt.rdtDropMsg 130801, 130850

execute rdt.rdtAddMsg 130801, 10, '30801^Need Value   ', 'us_english', 608
execute rdt.rdtAddMsg 130802, 10, '30802^Wrong Price  ', 'us_english', 608

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130801 AND 130850