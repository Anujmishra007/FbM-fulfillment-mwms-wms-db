-- ispHnMLblNoDecode04
EXEC RDT.RDTDROPMSG 131801 , 131850

execute rdt.rdtAddMsg 131801, 10, '31801^Invalid SKU',   'us_english', 841
execute rdt.rdtAddMsg 131802, 10, '31802^Invalid Lot02', 'us_english', 841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 131801 AND 131850
