--rdtfnc_Tore_ConveyerMove_Single
--execute rdt.rdtdropmsg 90201 , 90250

execute rdt.rdtAddMsg 90201, 10, '90201^CASE/TOTE req',  'us_english'
execute rdt.rdtAddMsg 90202, 10, '90202^INVALID TOTENO',  'us_english'
execute rdt.rdtAddMsg 90203, 10, '90203^Station Req',    'us_english'
execute rdt.rdtAddMsg 90204, 10, '90204^BAD Station',    'us_english'
execute rdt.rdtAddMsg 90205, 10, '90205^Opt required',    'us_english'
execute rdt.rdtAddMsg 90206, 10, '90206^Inv Option',    'us_english'
execute rdt.rdtAddMsg 90207, 10, '90207^RouteCreated',   'us_english'
execute rdt.rdtAddMsg 90208, 10, '90208^UpdWCSRouteFail',   'us_english'
execute rdt.rdtAddMsg 90209, 10, '90209^UpdWCSRouteDetFail',   'us_english'
execute rdt.rdtAddMsg 90210, 10, '90210^UpdWCSRouteFail',   'us_english'
execute rdt.rdtAddMsg 90211, 10, '90211^UpdWCSRouteDetFail',   'us_english'

execute rdt.rdtAddMsg 90212, 10, '90212^BAD Station',    'us_english'


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 90201 AND 90250