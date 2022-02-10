-- rdtfnc_Inquiry (range 60676 - 60700)
rdt.rdtDropMsg 60676 , 60700

execute rdt.rdtAddMsg 60676, 10, '60676 Value needed',   'us_english'
execute rdt.rdtAddMsg 60677, 10, '60677 ID/LOC/SKUOnly', 'us_english'
execute rdt.rdtAddMsg 60678, 10, '60678 Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 60679, 10, '60679 Diff facility',  'us_english'
execute rdt.rdtAddMsg 60680, 10, '60680 Invalid ID',     'us_english'
execute rdt.rdtAddMsg 60681, 10, '60681 Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 60682, 10, '60682 No record',      'us_english'
execute rdt.rdtAddMsg 60683, 10, '60683 No record',      'us_english'
execute rdt.rdtAddMsg 60684, 10, '60684 No record',      'us_english'

--SOS315607
execute rdt.rdtAddMsg 60685, 10, '60685^NotInStorerGrp', 'us_english'

--IN00025335
execute rdt.rdtAddMsg 60686, 10, '60686^Invalid Record', 'us_english'

--WMS9710
execute rdt.rdtAddMsg 60687, 10, '60687^Invalid Format', 'us_english'

execute rdt.rdtDropMsg 11 -- 'No records (LOC)'
execute rdt.rdtDropMsg 12 -- 'No records (PID)'
execute rdt.rdtDropMsg 13 -- 'Enter Value!'
