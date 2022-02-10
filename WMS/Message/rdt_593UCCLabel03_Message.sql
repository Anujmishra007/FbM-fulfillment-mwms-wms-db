--rdt_593UCCLabel03
exec rdt.rdtDropMsg 110051 , 110100

execute rdt.rdtAddMsg 110051, 10, '10051^Label Required',   'us_english', 593
execute rdt.rdtAddMsg 110052, 10, '10052^No Record',        'us_english', 593
execute rdt.rdtAddMsg 110053, 10, '10053^Diff Storer',      'us_english', 593
execute rdt.rdtAddMsg 110054, 10, '10054^LabelPrnterReq',   'us_english', 593
execute rdt.rdtAddMsg 110055, 10, '10055^DWNOTSetup',       'us_english', 593
execute rdt.rdtAddMsg 110056, 10, '10056^TgetDB Not Set',   'us_english', 593
execute rdt.rdtAddMsg 110057, 10, '10057^CARTON LABEL:',    'us_english', 593
execute rdt.rdtAddMsg 110058, 10, '10058^PICKSLIP NO:',     'us_english', 593
execute rdt.rdtAddMsg 110059, 10, '10059^SCANNED CARTON:',  'us_english', 593

select * from rdt.rdtmsg (nolock) where message_id between 110051 and 110100