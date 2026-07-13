--237301 - 237350
rdt.rdtDropMsg 237301 , 237350		

execute rdt.rdtAddMsg 237301, 10, '237301Invalid From LOC',    'us_english', 927
execute rdt.rdtAddMsg 237302, 10, '237302Invalid PalletID',    'us_english', 927
execute rdt.rdtAddMsg 237303, 10, '237303Pallet Shipped'  ,    'us_english', 927
execute rdt.rdtAddMsg 237304, 10, '237304Invalid Carton ID',               'us_english', 927
execute rdt.rdtAddMsg 237305, 10, '237305Insert DataCapture SHIPPED Failed', 'us_english', 927
execute rdt.rdtAddMsg 237306, 10, '237306Insert DataCapture Pallet Failed',  'us_english', 927
execute rdt.rdtAddMsg 237308, 10, '237308Insert DataCapture Carton Failed',  'us_english', 927
execute rdt.rdtAddMsg 237309, 10, '237309Insert DataCapture UCC Carton Failed', 'us_english', 927
execute rdt.rdtAddMsg 237312, 10, '237312Update MobRec Failed',              'us_english', 927

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 237301 AND 237350