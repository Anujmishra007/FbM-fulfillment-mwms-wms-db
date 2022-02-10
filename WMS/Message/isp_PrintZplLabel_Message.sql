-- isp_PrintZplLabel 
execute rdt.rdtDropMsg 101901 , 101950

execute rdt.rdtAddMsg 101901, 10, '01901^Setup CODEKLP',    'us_english'
execute rdt.rdtAddMsg 101902, 10, '01902^No Print Data',    'us_english'
execute rdt.rdtAddMsg 101903, 10, '01903^No Printer',       'us_english'
execute rdt.rdtAddMsg 101904, 10, '01904^Print Error',      'us_english'
execute rdt.rdtAddMsg 101905, 10, '01905^Print Error',      'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 101901 AND 101950
