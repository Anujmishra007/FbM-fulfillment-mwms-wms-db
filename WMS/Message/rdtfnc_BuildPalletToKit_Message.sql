/********************************************************
rdtfnc_BuildPalletToKit --663
********************************************************/

EXECUTE rdt.rdtDropMsg 234751, 234800

EXECUTE rdt.rdtAddMsg 234751 ,10, '234751Kit#Required',         'us_english', 663, 0, '234751: KIT ticket#/Extern Ticket# is required'
EXECUTE rdt.rdtAddMsg 234752 ,10, '234752KeyIn1Field',          'us_english', 663, 0, '234752: Key-in kit ticket# or Extern Ticket#'
EXECUTE rdt.rdtAddMsg 234753 ,10, '234753ExtKit#NotExist',      'us_english', 663, 0, '234753: Extern Ticket# not exist'
EXECUTE rdt.rdtAddMsg 234754 ,10, '234754MultiKitFound',        'us_english', 663, 0, '234754: Multiple kit ticket# found'
EXECUTE rdt.rdtAddMsg 234755 ,10, '234755KitNotExist',          'us_english', 663, 0, '234755: Kit not exist'
EXECUTE rdt.rdtAddMsg 234756 ,10, '234756KitDetailNotExist',    'us_english', 663, 0, '234756: Kit detail not exist'
EXECUTE rdt.rdtAddMsg 234757 ,10, '234757DiffFacility',         'us_english', 663, 0, '234757: Different facility'
EXECUTE rdt.rdtAddMsg 234758 ,10, '234758NotInStorerGrp',       'us_english', 663, 0, '234758: Not in the storer group'
EXECUTE rdt.rdtAddMsg 234759 ,10, '234759DiffStorer',           'us_english', 663, 0, '234759: Different storer'
EXECUTE rdt.rdtAddMsg 234760 ,10, '234760KitClosed',            'us_english', 663, 0, '234760: Kit is closed'
EXECUTE rdt.rdtAddMsg 234761 ,10, '234761NeedLoc',              'us_english', 663, 0, '234761: ToLoc is required'
EXECUTE rdt.rdtAddMsg 234762 ,10, '234762InvalidLoc',           'us_english', 663, 0, '234762: Invalid location'
EXECUTE rdt.rdtAddMsg 234763 ,10, '234763DiffFacility',         'us_english', 663, 0, '234763: Different facility'
EXECUTE rdt.rdtAddMsg 234764 ,10, '234764InvalidFormat',        'us_english', 663, 0, '234764: Invalid format'
EXECUTE rdt.rdtAddMsg 234765 ,10, '234765IDInUse',              'us_english', 663, 0, '234765: ID is in use'
EXECUTE rdt.rdtAddMsg 234766 ,10, '234766DuplicateID',          'us_english', 663, 0, '234766: ID is used in current kit#'
EXECUTE rdt.rdtAddMsg 234767 ,10, '234767NeedPalletType',       'us_english', 663, 0, '234767: Pallet type is required'
EXECUTE rdt.rdtAddMsg 234768 ,10, '234768InvPltType',           'us_english', 663, 0, '234768: Invalid pallet type'
EXECUTE rdt.rdtAddMsg 234769 ,10, '234769PltNotInUse',          'us_english', 663, 0, '234769: Pallet type not in use'
EXECUTE rdt.rdtAddMsg 234770 ,10, '234770InvalidSKU',           'us_english', 663, 0, '234770: Invalid SKU'
EXECUTE rdt.rdtAddMsg 234771 ,10, '234771MultiSKU',             'us_english', 663, 0, '234771: Multiple SKU Barcode'
EXECUTE rdt.rdtAddMsg 234772 ,10, '234772InvalidQty',           'us_english', 663, 0, '234772: Invalid Quantity'
EXECUTE rdt.rdtAddMsg 234773 ,10, '234773DecimalErr',           'us_english', 663, 0, '234773: Decimal Error'
EXECUTE rdt.rdtAddMsg 234774 ,10, '234774InvalidQty',           'us_english', 663, 0, '234774: Invalid Quantity'
EXECUTE rdt.rdtAddMsg 234775 ,10, '234775ConvDecimalErr',       'us_english', 663, 0, '234775: Convert to decimal qty error'
EXECUTE rdt.rdtAddMsg 234776 ,10, '234776InvalidQty',           'us_english', 663, 0, '234776: Invalid Quantity'
EXECUTE rdt.rdtAddMsg 234777 ,10, '234777OccupiedID',           'us_english', 663, 0, '234777: ID is used in another kit#'
EXECUTE rdt.rdtAddMsg 234778 ,10, '234778NoPalletType',         'us_english', 663, 0, '234778: No pallet type configured'
EXECUTE rdt.rdtAddMsg 234779 ,10, '234779NeedToID',             'us_english', 663, 0, '234779: Need To ID'
EXECUTE rdt.rdtAddMsg 234780 ,10, '234780SKURequired',          'us_english', 663, 0, '234780: SKU is required'

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN  234751 AND 234800
