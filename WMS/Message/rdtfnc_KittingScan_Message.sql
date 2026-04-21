--rdtfnc_KittingScan_Message

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1880)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1880, 'ENG', 'FNC', 'Kitting Scan', 'rdtfnc_KittingScan', '4')
END

EXEC rdt.rdtdropmsg 263801, 263850

EXECUTE rdt.rdtAddMsg 263801, 10, '263801^Scan KitKey',          'us_english', 1880, 0, '263801 Scan KitKey'
EXECUTE rdt.rdtAddMsg 263802, 10, '263802^Invalid KIT Status',   'us_english', 1880, 0, '263802 Invalid KIT Status'
EXECUTE rdt.rdtAddMsg 263803, 10, '263803^Need To Loc',          'us_english', 1880, 0, '263803 Need To Loc'
EXECUTE rdt.rdtAddMsg 263804, 10, '263804^To ID required',       'us_english', 1880, 0, '263804 To ID required'
EXECUTE rdt.rdtAddMsg 263805, 10, '263805^SKU is required',      'us_english', 1880, 0, '263805 SKU is required'
EXECUTE rdt.rdtAddMsg 263806, 10, '263806^QTY required',         'us_english', 1880, 0, '263806 QTY required'
EXECUTE rdt.rdtAddMsg 263807, 10, '263807^Invalid QTY',          'us_english', 1880, 0, '263807 Invalid QTY'
EXECUTE rdt.rdtAddMsg 263808, 10, '263808^Child SKU required',   'us_english', 1880, 0, '263808 Child SKU required'
EXECUTE rdt.rdtAddMsg 263809, 10, '263809^QTY required',         'us_english', 1880, 0, '263809 QTY required'
EXECUTE rdt.rdtAddMsg 263810, 10, '263810^Invalid QTY',          'us_english', 1880, 0, '263810 Invalid QTY'
EXECUTE rdt.rdtAddMsg 263811, 10, '263811^Invalid LOC',          'us_english', 1880, 0, '263811 Invalid LOC'
EXECUTE rdt.rdtAddMsg 263812, 10, '263812^Diff Facility',        'us_english', 1880, 0, '263812 Diff Facility'
EXECUTE rdt.rdtAddMsg 263813, 10, '263813^Invalid Loc type',     'us_english', 1880, 0, '263813 Invalid Loc type'
EXECUTE rdt.rdtAddMsg 263814, 10, '263814^Invalid ID format',    'us_english', 1880, 0, '263814 Invalid ID format'
EXECUTE rdt.rdtAddMsg 263815, 10, '263815^SKU not in Kit',       'us_english', 1880, 0, '263815 SKU not in Kit'
EXECUTE rdt.rdtAddMsg 263816, 10, '263816^QTY exceed expected',  'us_english', 1880, 0, '263816 QTY exceed expected'
EXECUTE rdt.rdtAddMsg 263817, 10, '263817^SKU not in BOM',       'us_english', 1880, 0, '263817 SKU not in BOM'
EXECUTE rdt.rdtAddMsg 263818, 10, '263818^QTY exceeds expected', 'us_english', 1880, 0, '263818 QTY exceeds expected'
EXECUTE rdt.rdtAddMsg 263819, 10, '263819^QTY mismatch',         'us_english', 1880, 0, '263819 QTY mismatch'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 263801 AND 263850
