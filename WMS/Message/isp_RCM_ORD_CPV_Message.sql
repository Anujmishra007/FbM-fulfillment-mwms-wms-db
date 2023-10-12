-- isp_RCM_ORD_CPV
execute rdt.rdtDropMsg 206901, 206950

execute rdt.rdtAddMsg 206901, 10, '206901OrderAllocated', 'us_english', 631
execute rdt.rdtAddMsg 206902, 10, '206902Error Allocate', 'us_english', 631
