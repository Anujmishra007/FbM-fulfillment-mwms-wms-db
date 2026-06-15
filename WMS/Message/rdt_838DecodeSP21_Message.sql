-- 269851 - 269900

EXECUTE rdt.rdtDropMsg 269851, 269900

EXECUTE rdt.rdtAddMsg 269851, 10, '269851^Invalid SKU prefix',       'us_english', 838, 0, '269851: SKU must start with NP (Fertin label 49)'
EXECUTE rdt.rdtAddMsg 269852, 10, '269852^SKU not found',            'us_english', 838, 0, '269852: SKU does not exist in system (Fertin label 49)'
EXECUTE rdt.rdtAddMsg 269853, 10, '269853^Invalid SKU prefix',       'us_english', 838, 0, '269853: SKU must start with NP (Swedish label 57)'
EXECUTE rdt.rdtAddMsg 269854, 10, '269854^SKU not found',            'us_english', 838, 0, '269854: SKU does not exist in system (Swedish label 57)'
EXECUTE rdt.rdtAddMsg 269855, 10, '269855^Invalid SKU prefix',       'us_english', 838, 0, '269855: SKU must start with NP (Swedish label 58)'
EXECUTE rdt.rdtAddMsg 269856, 10, '269856^SKU not found',            'us_english', 838, 0, '269856: SKU does not exist in system (Swedish label 58)'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 269851 AND 269900
