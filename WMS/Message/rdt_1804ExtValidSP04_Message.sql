-- rdt_1804ExtValidSP04
exec rdt.rdtDropMsg 122951 , 123000

execute rdt.rdtAddMsg 122951, 10, '22951^QTY <> CASECNT',      'us_english', 1804
execute rdt.rdtAddMsg 122952, 10, '22952^NoLabelPrinter',      'us_english', 1804

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 122951 AND 123000
