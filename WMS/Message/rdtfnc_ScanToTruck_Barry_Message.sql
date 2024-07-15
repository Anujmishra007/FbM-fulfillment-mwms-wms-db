rdt.rdtDropMsg 218451 , 218500		

execute rdt.rdtAddMsg 218451, 10, '218451Invalid Truck ID',    'us_english', 925
execute rdt.rdtAddMsg 218452, 10, '218452Truck Not Check In',    'us_english', 925
execute rdt.rdtAddMsg 218453, 10, '218453Invalid Option',    'us_english', 925
execute rdt.rdtAddMsg 218454, 10, '218454Invalid Pallet ID',    'us_english', 925
execute rdt.rdtAddMsg 218455, 10, '218455Already Loaded To Truck',    'us_english', 925
execute rdt.rdtAddMsg 218456, 10, '218456Pallet Cannot Be Blank',    'us_english', 925

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 218451 AND 218500	