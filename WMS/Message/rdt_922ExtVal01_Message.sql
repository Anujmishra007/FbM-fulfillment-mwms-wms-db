--rdt_922ExtVal01
execute rdt.rdtdropmsg 50651, 50700

execute rdt.rdtAddMsg '50651', 10, '50651^Order PendCanc', 'us_english', 922
execute rdt.rdtAddMsg '50652', 10, '50652^Order PendPack', 'us_english', 922
execute rdt.rdtAddMsg '50653', 10, '50653^Ord StatusOpen', 'us_english', 922
execute rdt.rdtAddMsg '50654', 10, '50654^Diff Shipper  ', 'us_english', 922
execute rdt.rdtAddMsg '50655', 10, '50655^Ord StatusHold', 'us_english', 922
execute rdt.rdtAddMsg '50656', 10, '50656^ExceedMaxOrder', 'us_english', 922
execute rdt.rdtAddMsg '50657', 10, '50657^AdyInDiffMBOL ', 'us_english', 922
