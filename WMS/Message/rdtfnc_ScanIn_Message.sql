-- rdtfnc_ScanIn
EXEC rdt.rdtDropMsg 172601 , 172650

execute rdt.rdtAddMsg 172601, 10, '172601 Pkslip needed',   'us_english', 1589
execute rdt.rdtAddMsg 172602, 10, '172602 InvalidPKSlip',   'us_english', 1589
execute rdt.rdtAddMsg 172603, 10, '172603 PS Scanned In',   'us_english', 1589
execute rdt.rdtAddMsg 172604, 10, '172604 Need PickerId',   'us_english', 1589
execute rdt.rdtAddMsg 172605, 10, '172605 Diff Storer  ',   'us_english', 1589
execute rdt.rdtAddMsg 172606, 10, '172606 Diff Facility',   'us_english', 1589
execute rdt.rdtAddMsg 172607, 10, '172607 Order Shipped',   'us_english', 1589
execute rdt.rdtAddMsg 172608, 10, '172608 ScanIn Failed',   'us_english', 1589
execute rdt.rdtAddMsg 172609, 10, '172609 ScanInSuccess',   'us_english', 1589

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 172601 AND 172650


