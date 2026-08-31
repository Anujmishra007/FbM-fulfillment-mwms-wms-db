-- rdt_839Confirm17 279201 - 279250
-- FCR-12865: add the logic for SNnotRequired.
execute rdt.rdtdropmsg 279201, 279250

-- UCC confirm
EXECUTE rdt.rdtAddMsg 279201, 10, '279201 UpdPKDtlFail',   'us_english', 839, 0, '279201 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 279202, 10, '279202 UpdUCCFail',     'us_english', 839, 0, '279202 Update UCC failed'
EXECUTE rdt.rdtAddMsg 279203, 10, '279203 UpdPKDtlFail',   'us_english', 839, 0, '279203 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 279204, 10, '279204 UpdPKDtlFail',   'us_english', 839, 0, '279204 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 279205, 10, '279205 UpdUCCFail',     'us_english', 839, 0, '279205 Update UCC failed'
EXECUTE rdt.rdtAddMsg 279206, 10, '279206 UpdPKDtlFail',   'us_english', 839, 0, '279206 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 279207, 10, '279207 UpdUCCFail',     'us_english', 839, 0, '279207 Update UCC failed'
EXECUTE rdt.rdtAddMsg 279208, 10, '279208 UpdPKDtlFail',   'us_english', 839, 0, '279208 Update PickDetail failed'

-- Short piece confirm
EXECUTE rdt.rdtAddMsg 279209, 10, '279209 UpdPKDtlFail',   'us_english', 839, 0, '279209 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 279210, 10, '279210 UpdPKDtlFail',   'us_english', 839, 0, '279210 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 279211, 10, '279211 GenKeyFail',     'us_english', 839, 0, '279211 Generate key failed'
EXECUTE rdt.rdtAddMsg 279212, 10, '279212 InsPKDtlFail',   'us_english', 839, 0, '279212 Insert PickDetail failed'
EXECUTE rdt.rdtAddMsg 279213, 10, '279213 UpdPKDtlFail',   'us_english', 839, 0, '279213 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 279214, 10, '279214 DelPKLogFail',   'us_english', 839, 0, '279214 Delete rdtPickLog failed'
EXECUTE rdt.rdtAddMsg 279215, 10, '279215 UpdPKLogFail',   'us_english', 839, 0, '279215 Update rdtPickLog failed'

-- Normal piece confirm (no serial no)
EXECUTE rdt.rdtAddMsg 279216, 10, '279216 UpdPKDtlFail',   'us_english', 839, 0, '279216 Update PickDetail failed'

-- Pick log cleanup
EXECUTE rdt.rdtAddMsg 279217, 10, '279217 DelPKLogFail',   'us_english', 839, 0, '279217 Delete rdtPickLog failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 279201 AND 279250
