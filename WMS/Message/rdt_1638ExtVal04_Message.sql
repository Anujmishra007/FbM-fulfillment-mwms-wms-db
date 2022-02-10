--rdt_1638ExtVal04
execute rdt.rdtDropMsg 119651, 119700

execute rdt.rdtAddMsg 119651, 10, '19651^DiffShip/PO/BU',   'us_english', 1638
execute rdt.rdtAddMsg 119652, 10, '19652^Diff ShipTo/BU',   'us_english', 1638
execute rdt.rdtAddMsg 119653, 10, '19653^Diff PO/BU',       'us_english', 1638

--WMS9882
execute rdt.rdtAddMsg 119654, 10, '19654^Diff Mark4Key',    'us_english', 1638

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 119651 AND 119700