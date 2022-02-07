--rdt.rdtfnc_ChangePassWord
execute rdt.rdtdropmsg 90301, 90350    
execute rdt.rdtAddMsg 90301, 10, '90301^User Needed   ', 'us_english', 800
execute rdt.rdtAddMsg 90302, 10, '90302^NewPas Needed ', 'us_english', 800
execute rdt.rdtAddMsg 90303, 10, '90303^ConPas Needed ', 'us_english', 800
execute rdt.rdtAddMsg 90304, 10, '90304^Invalid User  ', 'us_english', 800
execute rdt.rdtAddMsg 90305, 10, '90305^Multiple Rec  ', 'us_english', 800
execute rdt.rdtAddMsg 90306, 10, '90306^NewPas UnMatch', 'us_english', 800
execute rdt.rdtAddMsg 90307, 10, '90307^Change Failed ', 'us_english', 800
