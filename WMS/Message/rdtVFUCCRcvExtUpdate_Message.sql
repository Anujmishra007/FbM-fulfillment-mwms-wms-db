-- rdtVFUCCRcvExtCheck
execute rdt.rdtDropMsg 81901, 81950

execute rdt.rdtAddMsg 81901, 10, '81901^FinalizeRDFail', 'us_english', 898
execute rdt.rdtAddMsg 81902, 10, '81902^GetKey Fail   ', 'us_english', 898
execute rdt.rdtAddMsg 81903, 10, '81903^InsTaskDetFail', 'us_english', 898
execute rdt.rdtAddMsg 81904, 10, '81904^DelSwapLogFail', 'us_english', 898
execute rdt.rdtAddMsg 81905, 10, '81905^Invalid format', 'us_english', 898
execute rdt.rdtAddMsg 81906, 10, '81906^No RD Finalize', 'us_english', 898
execute rdt.rdtAddMsg 81907, 10, '81907^Not for XD ASN', 'us_english', 898
