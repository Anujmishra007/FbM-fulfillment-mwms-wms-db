-- rdt_850ExtValid01
execute rdt.rdtdropmsg 102701 , 102750

execute rdt.rdtAddMsg 102701 ,10, '02701^DWNOTSetup',       'us_english'
execute rdt.rdtAddMsg 102702 ,10, '02702^TgetDB Not Set',   'us_english'
execute rdt.rdtAddMsg 102703 ,10, '02703^PaperPrnterReq',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 102701 and 102750