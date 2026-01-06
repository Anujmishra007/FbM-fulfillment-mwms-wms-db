--rdt_855ExtValid07
--FCR-386
exec rdt.rdtDropMsg 216801, 216850

EXECUTE rdt.rdtAddMsg 216801, 10, '216801QTY:PICK!=PACK',     'us_english', 855
EXECUTE rdt.rdtAddMsg 216802, 10, '216802InvalidSKU',         'us_english', 855
EXECUTE rdt.rdtAddMsg 216803, 10, '216803InvlidOption',       'us_english', 855
EXECUTE rdt.rdtAddMsg 216804, 10, '216804NeedQC',             'us_english', 855
EXECUTE rdt.rdtAddMsg 216805, 10, '216805AuditFinished',      'us_english', 855
EXECUTE rdt.rdtAddMsg 216806, 10, '216806PickNotFinished',    'us_english', 855, 0, '216806 Pick is not finished'
EXECUTE rdt.rdtAddMsg 216807, 10, '216807QTY:PICK!=PACK',     'us_english', 855
EXECUTE rdt.rdtAddMsg 216808, 10, '216808PickNotFinished',    'us_english', 855, 0, '216808 Pick is not finished'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 216801 AND 216850