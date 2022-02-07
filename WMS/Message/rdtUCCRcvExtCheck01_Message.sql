-- rdtUCCRcvExtCheck01
execute rdt.rdtDropMsg 85301 , 85350

execute rdt.rdtAddMsg 85301, 10, '85301^UCCASNNotMatch', 'us_english', 898
execute rdt.rdtAddMsg 85302, 10, '85302^UCCPONotMatch ', 'us_english', 898
execute rdt.rdtAddMsg 85303, 10, '85303^Ins TLog3 Fail', 'us_english', 898
