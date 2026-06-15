-- 269901 - 269950

EXECUTE rdt.rdtDropMsg 269901, 269950

EXECUTE rdt.rdtAddMsg 269901, 10, '269901^Invalid SKU prefix',       'us_english', 861, 0, '269901: SKU must start with NP (Fertin label)'
EXECUTE rdt.rdtAddMsg 269902, 10, '269902^SKU not found',            'us_english', 861, 0, '269902: SKU does not exist in system (Fertin label)'
EXECUTE rdt.rdtAddMsg 269903, 10, '269903^Invalid SKU prefix',       'us_english', 861, 0, '269903: SKU must start with NP (Swedish label 57)'
EXECUTE rdt.rdtAddMsg 269904, 10, '269904^SKU not found',            'us_english', 861, 0, '269904: SKU does not exist in system (Swedish label 57)'
EXECUTE rdt.rdtAddMsg 269905, 10, '269905^Invalid SKU prefix',       'us_english', 861, 0, '269905: SKU must start with NP (Swedish label 58)'
EXECUTE rdt.rdtAddMsg 269906, 10, '269906^SKU not found',            'us_english', 861, 0, '269906: SKU does not exist in system (Swedish label 58)'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 269901 AND 269950
