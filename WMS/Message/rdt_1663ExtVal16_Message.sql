-- rdt_1663ExtVal16
exec rdt.rdtdropmsg 176151 , 176200

execute rdt.rdtAddMsg 176151, 10, '176151OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 176152, 10, '176152OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 176153, 10, '176153NotAllScanned ', 'us_english', 1663
execute rdt.rdtAddMsg 176154, 10, '176154Inv Track No  ', 'us_english', 1663
execute rdt.rdtAddMsg 176155, 10, '176155CtnCountXMatch', 'us_english', 1663
execute rdt.rdtAddMsg 176156, 10, '176156Inv Track No  ', 'us_english', 1663
execute rdt.rdtAddMsg 176157, 10, '176157InvalidPallet ', 'us_english', 1663
execute rdt.rdtAddMsg 176158, 10, '176158InvalidTrackNo', 'us_english', 1663
execute rdt.rdtAddMsg 176159, 10, '176159InvalidPallet ', 'us_english', 1663
execute rdt.rdtAddMsg 176160, 10, '176160InvalidTrackNo', 'us_english', 1663
execute rdt.rdtAddMsg 176161, 10, '176161Inv ShipperKey', 'us_english', 1663
execute rdt.rdtAddMsg 176162, 10, '176162Inv MBOL.UDF5 ', 'us_english', 1663
execute rdt.rdtAddMsg 176163, 10, '176163InvMBOL.OthRef', 'us_english', 1663

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 176151 AND 176200