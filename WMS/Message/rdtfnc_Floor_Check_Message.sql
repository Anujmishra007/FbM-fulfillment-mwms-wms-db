--237301 - 237350
rdt.rdtDropMsg 237301 , 237350		

execute rdt.rdtAddMsg 237301, 10, '237301Invalid From LOC',    'us_english', 927
execute rdt.rdtAddMsg 237302, 10, '237302Invalid PalletID',    'us_english', 927
execute rdt.rdtAddMsg 237303, 10, '237303Pallet Shipped'  ,    'us_english', 927
execute rdt.rdtAddMsg 237304, 10, '237304Invalid Carton ID',   'us_english', 927

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 237301 AND 237350