rdt.rdtDropMsg 218451 , 218500		

execute rdt.rdtAddMsg 218451, 10, '218451Invalid Truck ID',    'us_english', 925
execute rdt.rdtAddMsg 218452, 10, '218452Truck Not Check In',    'us_english', 925
execute rdt.rdtAddMsg 218453, 10, '218453Invalid Option',    'us_english', 925
execute rdt.rdtAddMsg 218454, 10, '218454Invalid Pallet ID',    'us_english', 925
execute rdt.rdtAddMsg 218455, 10, '218455Already Loaded To Truck',    'us_english', 925
execute rdt.rdtAddMsg 218456, 10, '218456Pallet Cannot Be Blank',    'us_english', 925
execute rdt.rdtAddMsg 218457, 10, '218457Seal1 Invalid',    'us_english', 925
execute rdt.rdtAddMsg 218458, 10, '218458Seal2 Invalid',    'us_english', 925
execute rdt.rdtAddMsg 218459, 10, '218459Seal3 Invalid',    'us_english', 925
execute rdt.rdtAddMsg 218460, 10, '218460Seal4 Invalid',    'us_english', 925
execute rdt.rdtAddMsg 218461, 10, '218461Seal5 Invalid',    'us_english', 925
execute rdt.rdtAddMsg 218462, 10, '218462Seal6 Invalid',    'us_english', 925
execute rdt.rdtAddMsg 218463, 10, '218463Invalid Pallet ID',    'us_english', 925

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 218451 AND 218500	
