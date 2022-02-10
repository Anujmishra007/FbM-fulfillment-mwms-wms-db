--rdt_855PrnPackList02
exec rdt.rdtDropMsg 116551 , 116600

execute rdt.rdtAddMsg 116551, 10, '16551^No Ctn Found',     'us_english', 855
execute rdt.rdtAddMsg 116552, 10, '16552^Order Cancel',     'us_english', 855
execute rdt.rdtAddMsg 116553, 10, '16553^UPD DropIDFail',   'us_english', 855
execute rdt.rdtAddMsg 116554, 10, 'Shipping Lbl Printed',   'us_english', 855
execute rdt.rdtAddMsg 116555, 10, 'Carton Lbl Printed',     'us_english', 855
execute rdt.rdtAddMsg 116556, 10, '16556^Not Last Ctn',     'us_english', 855
execute rdt.rdtAddMsg 116557, 10, '16557^UPD DropIDFail',   'us_english', 855
execute rdt.rdtAddMsg 116558, 10, 'Content Lbl Printed',    'us_english', 855

select * from rdt.rdtmsg (nolock) where message_id between 116551 and 116600



