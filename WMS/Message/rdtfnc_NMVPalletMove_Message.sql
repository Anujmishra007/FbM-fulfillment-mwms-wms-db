-- rdtfnc_NMVPalletMove
exec rdt.rdtDropMsg 75051, 75100
 
execute rdt.rdtAddMsg 75051, 10, '75051^Need ID       ', 'us_english', 1791
execute rdt.rdtAddMsg 75052, 10, '75052^Invalid ID    ', 'us_english', 1791
execute rdt.rdtAddMsg 75053, 10, '75053^ID PACK&HOLD  ', 'us_english', 1791
execute rdt.rdtAddMsg 75054, 10, '75054^ID had shipped', 'us_english', 1791
execute rdt.rdtAddMsg 75055, 10, '75055^ID no LoadKey ', 'us_english', 1791
execute rdt.rdtAddMsg 75056, 10, '75056^IDMultiLoadKey', 'us_english', 1791
execute rdt.rdtAddMsg 75057, 10, '75057^NoSuggestedLOC', 'us_english', 1791
execute rdt.rdtAddMsg 75058, 10, '75058^Need Final LOC', 'us_english', 1791
execute rdt.rdtAddMsg 75059, 10, '75059^Invalid LOC   ', 'us_english', 1791
execute rdt.rdtAddMsg 75060, 10, '75060^Diff facility ', 'us_english', 1791
execute rdt.rdtAddMsg 75061, 10, '75061^LOC Not Match ', 'us_english', 1791
execute rdt.rdtAddMsg 75062, 10, '75062^Diff ShipTo+PO', 'us_english', 1791
execute rdt.rdtAddMsg 75063, 10, '75063^LOC Not Match ', 'us_english', 1791
execute rdt.rdtAddMsg 75064, 10, '75064^EXCEED MAX PLT', 'us_english', 1791
execute rdt.rdtAddMsg 75065, 10, '75065^UpdDropIDFail ', 'us_english', 1791
execute rdt.rdtAddMsg 75066, 10, 'PACK & HOLD LOC FULL', 'us_english', 1791
execute rdt.rdtAddMsg 75067, 10, '75067^ID STAGED     ', 'us_english', 1791

--SOS248014
execute rdt.rdtAddMsg 75068, 10, '75068^ID AUDIT FAIL',  'us_english', 1791



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 75051 AND 75100
