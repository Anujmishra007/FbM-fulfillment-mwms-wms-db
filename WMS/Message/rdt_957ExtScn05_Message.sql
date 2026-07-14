--rdt_957ExtScn05
--FCR-7823
execute rdt.rdtdropmsg 273101, 273150

execute rdt.rdtAddMsg 273101, 10, '273101 OptionRequired',   'us_english', 957, 0, '273101 Option is required'
execute rdt.rdtAddMsg 273102, 10, '273102 InvalidOption',    'us_english', 957, 0, '273102 Invalid option'
execute rdt.rdtAddMsg 273103, 10, '273103 LocRequired',      'us_english', 957, 0, '273103 Location is required'
execute rdt.rdtAddMsg 273104, 10, '273104 InvalidLoc',       'us_english', 957, 0, '273104 Invalid location'
execute rdt.rdtAddMsg 273105, 10, '273105 UpdPkDtlFail',     'us_english', 957, 0, '273105 Update PickDetail failed'
execute rdt.rdtAddMsg 273106, 10, '273106 MoveUCCFail',      'us_english', 957, 0, '273106 Move UCC failed'
execute rdt.rdtAddMsg 273107, 10, '273107 DropPalletFail',   'us_english', 957, 0, '273107 Drop pallet failed'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 273101 AND 273150
