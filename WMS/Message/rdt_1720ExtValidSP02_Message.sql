--rdt_1720ExtValidSP02
-- FCR-8808
EXECUTE rdt.rdtDropMsg 253101, 253150

EXECUTE rdt.rdtAddMsg '253101', 10, '253101PalletScanToTruck',    'us_english', 1720, 0, '253101 Pallet was Scaned To Truck'
EXECUTE rdt.rdtAddMsg '253102', 10, '253102PalletShipped',        'us_english', 1720, 0, '253102 Pallet was Shipped'
EXECUTE rdt.rdtAddMsg '253103', 10, '253103PalletScanToTruck',    'us_english', 1720, 0, '253103 Pallet was Scaned To Truck'
EXECUTE rdt.rdtAddMsg '253104', 10, '253104PalletShipped',        'us_english', 1720, 0, '253104 Pallet was Shipped'
EXECUTE rdt.rdtAddMsg '253105', 10, '253105DiffMBOLs',            'us_english', 1720, 0, '253105 Different MBOLs'
EXECUTE rdt.rdtAddMsg '253106', 10, '253106DiffShipTo',           'us_english', 1720, 0, '253106 Different Ship-to'
EXECUTE rdt.rdtAddMsg '253107', 10, '253107SamePallet',           'us_english', 1720, 0, '253107 To Pallet cannot be the same as From Pallet'
EXECUTE rdt.rdtAddMsg '253108', 10, '253108InvalidTote',          'us_english', 1720, 0, '253108 Invalid Tote'
EXECUTE rdt.rdtAddMsg '253109', 10, '253109ToteScanToTruck',      'us_english', 1720, 0, '253109 Tote is scaned to truck'
EXECUTE rdt.rdtAddMsg '253110', 10, '253110ToteShipped',          'us_english', 1720, 0, '253110 Tote is shipped'
EXECUTE rdt.rdtAddMsg '253111', 10, '253111PalletNotClose',       'us_english', 1720, 0, '253111 Pallet is not closed'
EXECUTE rdt.rdtAddMsg '253112', 10, '253112NotMergePartial',      'us_english', 1720, 0, '253112 Not allow merge partial'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253101 AND 253150
