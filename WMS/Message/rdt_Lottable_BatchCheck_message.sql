--rdt_LottableProcess_BatchCheck
----Message 223701 to 223750
EXECUTE rdt.rdtDropMsg 223701, 223750

EXECUTE rdt.rdtAddMsg 223701, 10, '223701^Invalid format', 'us_english', 600
EXECUTE rdt.rdtAddMsg 223702, 10, '223702^Invalid B-Year', 'us_english', 600
EXECUTE rdt.rdtAddMsg 223703, 10, '223703^Invalid Config', 'us_english', 600
EXECUTE rdt.rdtAddMsg 223704, 10, '223704^Batch Mandatory', 'us_english', 600

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 223701 AND 223750
