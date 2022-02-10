-- rdt_850ExtUpdSP02 
execute rdt.rdtdropmsg 98551 , 98600


execute rdt.rdtAddMsg 98551 ,10, '98551^PaperPrnterReq',    'us_english'
execute rdt.rdtAddMsg 98552 ,10, '98552^DWNOTSetup',        'us_english'
execute rdt.rdtAddMsg 98553 ,10, '98553^TgetDB Not Set',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 98551 and 98600