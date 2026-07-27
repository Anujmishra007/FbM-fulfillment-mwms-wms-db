EXECUTE rdt.rdtDropMsg 274601, 274650

EXECUTE rdt.rdtAddMsg 274601, 10, '274601 EnterKITTicket',  'us_english', 1881, 0,  '274601 Enter KIT Ticket#'
EXECUTE rdt.rdtAddMsg 274602, 10, '274602 InvKITTicket',    'us_english', 1881, 0,  '274602 Invalid KIT Ticket#'
EXECUTE rdt.rdtAddMsg 274603, 10, '274603 DiffFacility',    'us_english', 1881, 0,  '274603 Different Facility'
EXECUTE rdt.rdtAddMsg 274604, 10, '274604 DiffStorer',      'us_english', 1881, 0,  '274604 Different Storer'
EXECUTE rdt.rdtAddMsg 274605, 10, '274605 KITFinalized',    'us_english', 1881, 0,  '274605 KIT is Finalized'
EXECUTE rdt.rdtAddMsg 274606, 10, '274606 ScanLOC',         'us_english', 1881, 0,  '274606 Scan LOC'
EXECUTE rdt.rdtAddMsg 274607, 10, '274607 NotKITLoc',       'us_english', 1881, 0,  '274607 Not KIT Location'
EXECUTE rdt.rdtAddMsg 274608, 10, '274608 ScanPalletID',    'us_english', 1881, 0,  '274608 Scan Pallet ID'
EXECUTE rdt.rdtAddMsg 274609, 10, '274609 PalletNotFound',  'us_english', 1881, 0,  '274609 Pallet NOT found'
EXECUTE rdt.rdtAddMsg 274610, 10, '274610 ChkKITDtlStatus', 'us_english', 1881, 0,  '274610 Check KITDETAIL status'
EXECUTE rdt.rdtAddMsg 274611, 10, '274611 ScanSKU',         'us_english', 1881, 0,  '274611 Scan SKU'
EXECUTE rdt.rdtAddMsg 274612, 10, '274612 SKUNotOnPallet',  'us_english', 1881, 0,  '274612 SKU NOT on the pallet'
EXECUTE rdt.rdtAddMsg 274613, 10, '274613 EnterQTY',        'us_english', 1881, 0,  '274613 Enter QTY'
EXECUTE rdt.rdtAddMsg 274614, 10, '274614 InvQTY',          'us_english', 1881, 0,  '274614 Invalid QTY'
EXECUTE rdt.rdtAddMsg 274615, 10, '274615 NoKITDtlMatch',   'us_english', 1881, 0,  '274615 No matching KITDETAIL found'
EXECUTE rdt.rdtAddMsg 274616, 10, '274616 QTYOverExpected', 'us_english', 1881, 0,  '274616 QTY more than expected'
EXECUTE rdt.rdtAddMsg 274617, 10, '274617 EnterTOLOC',     'us_english', 1881, 0,  '274617 Enter TO LOC'
EXECUTE rdt.rdtAddMsg 274618, 10, '274618 MoveFailed',     'us_english', 1881, 0,  '274618 Move failed'
EXECUTE rdt.rdtAddMsg 274619, 10, '274619 KITDtlUpdFail',  'us_english', 1881, 0,  '274619 KITDETAIL update failed'
EXECUTE rdt.rdtAddMsg 274620, 10, '274620 KITDtlUpdFail2', 'us_english', 1881, 0,  '274620 KITDETAIL update failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 274601 AND 274650
