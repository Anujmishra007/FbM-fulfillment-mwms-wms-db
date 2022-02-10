
-- rdt_840ExtUpd03 
execute rdt.rdtDropMsg 101301 , 101350

execute rdt.rdtAddMsg 101301, 10, '01301^Need OrderKey',     'us_english'
execute rdt.rdtAddMsg 101302, 10, '01302^NoPaperPrinter',    'us_english'
execute rdt.rdtAddMsg 101303, 10, '01303^DWNOTSetup',        'us_english'
execute rdt.rdtAddMsg 101304, 10, '01304^TgetDB Not Set',    'us_english'
execute rdt.rdtAddMsg 101305, 10, '01305^NO PKSLIP',         'us_english'
execute rdt.rdtAddMsg 101306, 10, '01306^NO ORDERKEY',       'us_english'
execute rdt.rdtAddMsg 101307, 10, '01307^Upd OdHdr Fail',    'us_english'
execute rdt.rdtAddMsg 101308, 10, '01308^Upd OdDtl Fail',    'us_english'
execute rdt.rdtAddMsg 101309, 10, '01309^Upd LpDtl Fail',    'us_english'
execute rdt.rdtAddMsg 101310, 10, '01310^nspGetRightErr',    'us_english'
execute rdt.rdtAddMsg 101311, 10, '01311^GenTLog3 Fail',     'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 101301 and 101350