--rdt_TrackNo_SortToPallet_CreateMbol
exec rdt.rdtDropMsg 191301 , 191350

execute rdt.rdtAddMsg 191301, 10, '191301 Del PltDtl Er',   'us_english', 1653
execute rdt.rdtAddMsg 191302, 10, '191302 Del PltHdr Er',   'us_english', 1653
execute rdt.rdtAddMsg 191303, 10, '191303INS PalletFail',   'us_english', 1653
execute rdt.rdtAddMsg 191304, 10, '191304 INS PLDtl Err',   'us_english', 1653
execute rdt.rdtAddMsg 191305, 10, '191305 GetKey Fail  ',   'us_english', 1653
execute rdt.rdtAddMsg 191306, 10, '191306 INS MBOL Fail',   'us_english', 1653
execute rdt.rdtAddMsg 191307, 10, '191307 MBOL Shipped ',   'us_english', 1653
execute rdt.rdtAddMsg 191308, 10, '191308 INS MBDtl Err',   'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191301 AND 191350

