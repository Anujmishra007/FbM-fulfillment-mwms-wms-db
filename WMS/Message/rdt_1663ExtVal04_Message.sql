-- rdt_1663ExtVal04
exec rdt.rdtdropmsg 129201, 129250

execute rdt.rdtAddMsg 129201, 10, '129201OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 129202, 10, '129202OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 129203, 10, '129203NotAllScanned ', 'us_english', 1663

--WMS-11821
execute rdt.rdtAddMsg 129204, 10, '129204Inv Track No  ', 'us_english', 1663

--WMS-12486
execute rdt.rdtAddMsg 129205, 10, '129205CtnCountXMatch', 'us_english', 1663
execute rdt.rdtAddMsg 129206, 10, '129206Inv Track No  ', 'us_english', 1663

execute rdt.rdtAddMsg 129207, 10, '129207InvalidPallet ', 'us_english', 1663
execute rdt.rdtAddMsg 129208, 10, '129208InvalidTrackNo', 'us_english', 1663
execute rdt.rdtAddMsg 129209, 10, '129209InvalidPallet ', 'us_english', 1663
execute rdt.rdtAddMsg 129210, 10, '129210InvalidTrackNo', 'us_english', 1663

-- WMS-17778
execute rdt.rdtAddMsg 129211, 10, '129211Inv ShipperKey', 'us_english', 1663