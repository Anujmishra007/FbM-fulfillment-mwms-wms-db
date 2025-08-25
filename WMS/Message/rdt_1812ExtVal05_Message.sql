--rdt_1812ExtVal05
--239651 - 239700

exec rdt.rdtDropMsg 239651 , 239700

execute rdt.rdtAddMsg 239651, 10, '239651InvalidQty',           'us_english', 1812, 0, '239651: Invalid Qty'
execute rdt.rdtAddMsg 239652, 10, '239652CannotOverwrite',      'us_english', 1812, 0, '239652: Cannot overwrite this location'
execute rdt.rdtAddMsg 239653, 10, '239653LocOnHold',            'us_english', 1812, 0, '239653: Location is on hold'
execute rdt.rdtAddMsg 239654, 10, '239654InvalidMarshalling',   'us_english', 1812, 0, '239654: Scan a marshalling lane of the same company not hold'
execute rdt.rdtAddMsg 239655, 10, '239655ScanDefaultLane',      'us_english', 1812, 0, '239655: All Marshalling lanes are hold. Scan the default one'
execute rdt.rdtAddMsg 239656, 10, '2396556ScanDefaultKitLoc',   'us_english', 1812, 0, '239656: All kitting LOCs are hold. Scan the default one'
execute rdt.rdtAddMsg 239657, 10, '2396557ScanDefaultKitLoc',   'us_english', 1812, 0, '239657: Scan an valid kitting loc not hold'
execute rdt.rdtAddMsg 239658, 10, '239658PNDIsFull',           'us_english', 1812, 0, '239658: PND location is full'
execute rdt.rdtAddMsg 239659, 10, '2396559CannotOverwrite',     'us_english', 1812, 0, '239659: CannotOverwrite'
execute rdt.rdtAddMsg 239660, 10, '2396560SOIsFullyPicked',     'us_english', 1812, 0, '239660: SOIsFullyPicked'


execute rdt.rdtAddMsg 239663, 10, '239663DefaultLaneNotFound',  'us_english', 1812, 0, '239663: Default marshalling lane not found'
execute rdt.rdtAddMsg 239664, 10, '239664DefaultLocNotFound',   'us_english', 1812, 0, '239664: Default kitting loc not found'
execute rdt.rdtAddMsg 239665, 10, '239665PleaseChooseAnOption',   'us_english', 1812, 0, '239665PleaseChooseAnOption'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 239651 AND 239700

