
-- rdtfnc_PostPackAudit_BatchPO_Capture Messages
-- **********************************************

--execute rdt.rdtDropMsg 66951, 66975

execute rdt.rdtAddMsg 66951, 10, '66951^Batch needed', 'us_english'
execute rdt.rdtAddMsg 66952, 10, '66952^BatchNotFound', 'us_english'
execute rdt.rdtAddMsg 66953, 10, '66953^BatchAlrdyClosed', 'us_english'
execute rdt.rdtAddMsg 66954, 10, '66954^PO# needed', 'us_english'
execute rdt.rdtAddMsg 66955, 10, '66955^POAlrdyExst', 'us_english'
execute rdt.rdtAddMsg 66956, 10, '66956^PO# Not Exists', 'us_english'
execute rdt.rdtAddMsg 66957, 10, '66957^Option needed', 'us_english'
execute rdt.rdtAddMsg 66958, 10, '66958^Invalid option', 'us_english'
execute rdt.rdtAddMsg 66959, 10, '66959^POAlrdyUsed', 'us_english'