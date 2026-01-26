-- rdt_1812ExtScn06
execute rdt.rdtDropMsg 180011 , 180020

execute rdt.rdtAddMsg 180011, 10, '180011 InvalidInput',    'us_english', 1812
execute rdt.rdtAddMsg 180012, 10, '180012 ',    'us_english', 1812 , 0 ,'No more open tasks for this wave and location'