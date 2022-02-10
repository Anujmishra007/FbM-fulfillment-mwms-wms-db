--rdt_523ExtPA22
rdt.rdtDropMsg 140901 , 140950	

execute rdt.rdtAddMsg 140901, 10, '40901^StrategyNotSet',   'us_english', 523
execute rdt.rdtAddMsg 140902, 10, '40902^BadStrategyKey',   'us_english', 523
execute rdt.rdtAddMsg 140903, 10, '40903^No Sugg Loc',      'us_english', 523

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 140901 AND 140950	