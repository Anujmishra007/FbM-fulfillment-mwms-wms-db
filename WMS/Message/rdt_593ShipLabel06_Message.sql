--rdt_593ShipLabel06
exec rdt.rdtDropMsg 110901 , 110950

execute rdt.rdtAddMsg 110901, 10, '10901^Label No Req',     'us_english', 593
execute rdt.rdtAddMsg 110902, 10, '10902^Invalid Label',    'us_english', 593
execute rdt.rdtAddMsg 110903, 10, '10903^LabelPrnterReq',   'us_english', 593
execute rdt.rdtAddMsg 110904, 10, '10904^DWNOTSetup',       'us_english', 593
execute rdt.rdtAddMsg 110905, 10, '10905^TgetDB Not Set',   'us_english', 593
execute rdt.rdtAddMsg 110906, 10, '10906^DWNOTSetup',       'us_english', 593
execute rdt.rdtAddMsg 110907, 10, '10907^TgetDB Not Set',   'us_english', 593
execute rdt.rdtAddMsg 110908, 10, '10908^Close Ctn Fail',   'us_english', 593

select * from rdt.rdtmsg (nolock) where message_id between 110901 and 110950