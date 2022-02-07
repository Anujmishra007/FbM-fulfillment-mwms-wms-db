--rdt_1628ExtValid02
exec rdt.rdtDropMsg 116101 , 116150

execute rdt.rdtAddMsg 116101, 10, '16101^Multi SKU UCC',   'us_english', 1620
execute rdt.rdtAddMsg 116102, 10, '16102^SKU Not Match',   'us_english', 1620
execute rdt.rdtAddMsg 116103, 10, '16103^QTY Not Match',   'us_english', 1620
execute rdt.rdtAddMsg 116104, 10, '16104^DOUBLE SCANNED',  'us_english', 1620
execute rdt.rdtAddMsg 116105, 10, '16105^UPD PKLOG FAIL',  'us_english', 1620
execute rdt.rdtAddMsg 116106, 10, '16106^INS PKLOG FAIL',  'us_english', 1620
execute rdt.rdtAddMsg 116107, 10, '16107^UPD PKLOG FAIL',  'us_english', 1620

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 116101 AND 116150
