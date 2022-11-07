--rdtfnc_TrackNo_SortToPallet_CloseLane
exec rdt.rdtDropMsg 191251 , 191300

execute rdt.rdtAddMsg 191251, 10, '191251 Need Lane    ',   'us_english', 1654
execute rdt.rdtAddMsg 191252, 10, '191252LaneHasOpenPlt',   'us_english', 1654
execute rdt.rdtAddMsg 191253, 10, '191253OrderNotPacked',   'us_english', 1654
execute rdt.rdtAddMsg 191254, 10, '191254 Need Option  ',   'us_english', 1654
execute rdt.rdtAddMsg 191255, 10, '191255Invalid Option',   'us_english', 1654
execute rdt.rdtAddMsg 191256, 10, '191256ValidateMBOLEr',   'us_english', 1654
execute rdt.rdtAddMsg 191257, 10, '191257MBOL Ship Fail',   'us_english', 1654
execute rdt.rdtAddMsg 191258, 10, 'NOT ALL CARTONS     ',   'us_english', 1654
execute rdt.rdtAddMsg 191259, 10, 'ARE SCANNED TO LANE ',   'us_english', 1654
execute rdt.rdtAddMsg 191260, 10, '191260 NOT ALL SCAN ',   'us_english', 1654
execute rdt.rdtAddMsg 191261, 10, '191261 Invalid Lane ',   'us_english', 1654
execute rdt.rdtAddMsg 191262, 10, '191262 Other Storer ',   'us_english', 1654
execute rdt.rdtAddMsg 191263, 10, '191263 Lane Closed  ',   'us_english', 1654

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191251 AND 191300

