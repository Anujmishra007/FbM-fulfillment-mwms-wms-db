-- rdt_TrackNoToPallet_Confirm
exec rdt.rdtdropmsg 111301, 111350

execute rdt.rdtAddMsg 111301, 10, '111301INS PLDtl Fail', 'us_english', 1663
execute rdt.rdtAddMsg 111302, 10, '111302INS MBDtl Fail', 'us_english', 1663
execute rdt.rdtAddMsg 111303, 10, '111303UPD MBDtl Fail', 'us_english', 1663
execute rdt.rdtAddMsg 111304, 10, '111304Missing PkInfo', 'us_english', 1663
execute rdt.rdtAddMsg 111305, 10, '111305Bad CartonType', 'us_english', 1663
execute rdt.rdtAddMsg 111306, 10, '111306MBOL Shipped  ', 'us_english', 1663

--WMS-17937
execute rdt.rdtAddMsg 111307, 10, '111307 Upd CtnTyp Er', 'us_english', 1663
execute rdt.rdtAddMsg 111308, 10, '111308 Upd Weight Er', 'us_english', 1663
execute rdt.rdtAddMsg 111309, 10, '111309 Upd Cube Er  ', 'us_english', 1663

