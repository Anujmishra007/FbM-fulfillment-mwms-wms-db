--rdt_1653ExtScn01
--FCR-950
exec rdt.rdtDropMsg 219151, 219200

execute rdt.rdtAddMsg 219151, 10, '219151Cannot override location',     'us_english', 1653
execute rdt.rdtAddMsg 219152, 10, '219152Need Pallet ID',               'us_english', 1653
execute rdt.rdtAddMsg 219153, 10, '219153Invalid Format',               'us_english', 1653
execute rdt.rdtAddMsg 219154, 10, '219154Pallet Not Match',             'us_english', 1653
execute rdt.rdtAddMsg 219155, 10, '219155LOC NOT FOUND',                'us_english', 1653
execute rdt.rdtAddMsg 219156, 10, '219156Location is required',         'us_english', 1653
execute rdt.rdtAddMsg 219157, 10, '219157TrackNoInUse',                 'us_english', 1653
execute rdt.rdtAddMsg 219158, 10, '219158CartonNotPacked',              'us_english', 1653
execute rdt.rdtAddMsg 219159, 10, '219159InvalidOption',                'us_english', 1653
execute rdt.rdtAddMsg 219160, 10, '219160RemoveCTNFail',                'us_english', 1653
execute rdt.rdtAddMsg 219161, 10, '219161NoUSIDOutPre',                 'us_english', 1653
execute rdt.rdtAddMsg 219162, 10, '219162InvalidPrefix',                'us_english', 1653
execute rdt.rdtAddMsg 219163, 10, '219163NoLocPre',                     'us_english', 1653
execute rdt.rdtAddMsg 219164, 10, '219164InvalidLoc',                   'us_english', 1653
execute rdt.rdtAddMsg 219165, 10, '219165LocOccupied',                  'us_english', 1653, 0, '219165 The location is occupied'
execute rdt.rdtAddMsg 219166, 10, '219166PalletExists',                 'us_english', 1653


SELECT * FROM RDT.RDTMsg WHERE Message_ID BETWEEN 219151 AND 219200