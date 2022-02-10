--rdt_1841ClosePlt03
exec rdt.rdtDropMsg 170551, 170600

execute rdt.rdtAddMsg 170551, 10, '170551No PALoc Found',   'us_english', 1841
execute rdt.rdtAddMsg 170552, 10, '170552StrategyNotSet',   'us_english', 1841
execute rdt.rdtAddMsg 170553, 10, '170553BadStrategyKey',   'us_english', 1841
execute rdt.rdtAddMsg 170554, 10, '170554GetKey Fail   ',   'us_english', 1841
execute rdt.rdtAddMsg 170555, 10, '170555CreatePATaskEr',   'us_english', 1841
execute rdt.rdtAddMsg 170556, 10, '170556Close Plt Fail',   'us_english', 1841
execute rdt.rdtAddMsg 170557, 10, '170557 Ivalid Lane  ',   'us_english', 1841


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 170551 AND 170600


