-- rdt_1812ExtValAU01 --  263151 - 263200
EXEC rdt.rdtDropMsg 263151 , 263200

EXECUTE rdt.rdtAddMsg 263151, 10, '263151 NeedDropID',            'us_english', 1812, 0, '263151 Need DropID'
EXECUTE rdt.rdtAddMsg 263152, 10, '263152 DropIDInUse',           'us_english', 1812, 0, '263152 DropID in use'
EXECUTE rdt.rdtAddMsg 263153, 10, '263153 InvalidDropID',         'us_english', 1812, 0, '263153 Invalid DropID'
EXECUTE rdt.rdtAddMsg 263154, 10, '263154 NoTaskClosePL',         'us_english', 1812, 0, '263154 No more tasks for the order. Close Pallet.'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263151 AND 263200  