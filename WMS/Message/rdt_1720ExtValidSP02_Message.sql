--rdt_1720ExtValidSP02
-- FCR-8808
EXECUTE rdt.rdtDropMsg 253101, 253150

EXECUTE rdt.rdtAddMsg '253101', 10, '253101PalletScanToTruck',    'us_english', 1720, 0, '253101 Pallet was Scaned To Truck'
EXECUTE rdt.rdtAddMsg '253102', 10, '253102PalletShipped',        'us_english', 1720, 0, '253102 Pallet was Shipped'
EXECUTE rdt.rdtAddMsg '253103', 10, '253103PalletScanToTruck',    'us_english', 1720, 0, '253103 Pallet was Scaned To Truck'
EXECUTE rdt.rdtAddMsg '253104', 10, '253104PalletShipped',        'us_english', 1720, 0, '253104 Pallet was Shipped'
EXECUTE rdt.rdtAddMsg '253105', 10, '253105DiffMBOLs',            'us_english', 1720, 0, '253105 Different MBOLs'
EXECUTE rdt.rdtAddMsg '253106', 10, '253106DiffShipTo',           'us_english', 1720, 0, '253106 Different Ship-to'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253101 AND 253150
