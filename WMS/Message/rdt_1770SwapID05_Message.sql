--rdt.rdt_1770SwapID05
--FCR-3836
-- UWP-39385
EXECUTE rdt.rdtdropmsg 236001, 236050

EXECUTE rdt.rdtAddMsg 236001, 10, '236001^Need ID       ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236002, 10, '236002^IDIsOnHold',            'us_english', 1770
EXECUTE rdt.rdtAddMsg 236003, 10, '236003^BadTaskDtlKey ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236004, 10, '236004^LocTypeNotMatch',       'us_english', 1770, 0, '236004 Loc Type Not Match'
EXECUTE rdt.rdtAddMsg 236005, 10, '236003^Invalid ID    ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236006, 10, '236006^PickStarted',           'us_english', 1770, 0, '236006 Pick Started, cannot swap ID'
EXECUTE rdt.rdtAddMsg 236007, 10, '236007^ID multi rec  ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236008, 10, '236008^LOC not match ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236009, 10, '236009^LOC not match ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236010, 10, '236010^QTY not match ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236011, 10, '236011^ID task taken ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236012, 10, '236012^Swap FP only  ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236013, 10, '236013^UpdPKDFail',            'us_english', 1770, 0, '236013 Unallocate Failed'
EXECUTE rdt.rdtAddMsg 236014, 10, '236014^UnallocateFail',        'us_english', 1770, 0, '236014 Unallocate Failed'
EXECUTE rdt.rdtAddMsg 236015, 10, '236015^AllocateFail',          'us_english', 1770, 0, '236015 Allocate Failed'
EXECUTE rdt.rdtAddMsg 236016, 10, '236016^AllocateFail',          'us_english', 1770, 0, '236016 Allocate Failed'
EXECUTE rdt.rdtAddMsg 236017, 10, '236017^AllocateFail',          'us_english', 1770, 0, '236017 Allocate Failed'
EXECUTE rdt.rdtAddMsg 236018, 10, '236018^AllocateFail',          'us_english', 1770, 0, '236018 Allocate Failed'
EXECUTE rdt.rdtAddMsg 236019, 10, '236019^UnlockPendMoveFail',    'us_english', 1770, 0, '236019 Unlock RPFPendingMoveIn Failed'

EXECUTE rdt.rdtAddMsg 236020, 10, '236020^Lot01NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236021, 10, '236021^Lot02NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236022, 10, '236022^Lot03NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236023, 10, '236023^Lot04NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236024, 10, '236024^Lot05NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236025, 10, '236025^Lot06NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236026, 10, '236026^Lot07NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236027, 10, '236027^Lot08NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236028, 10, '236028^Lot09NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236029, 10, '236029^Lot10NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236030, 10, '236030^Lot11NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236031, 10, '236031^Lot12NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236032, 10, '236032^Lot13NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236033, 10, '236033^Lot14NotMatch',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236034, 10, '236034^Lot15NotMatch',         'us_english', 1770

EXECUTE rdt.rdtAddMsg 236035, 10, '236035^ReleaseQTYReplenFailed', 'us_english', 1770, 0, '236035 Release QTYReplen Failed'
EXECUTE rdt.rdtAddMsg 236036, 10, '236036^SwapQTYReplenFailed',   'us_english', 1770, 0, '236036 Swap QTYReplen Failed'
EXECUTE rdt.rdtAddMsg 236037, 10, '236037^UnlockPendMoveFail',    'us_english', 1770, 0, '236037 Unlock RPFPendingMoveIn Failed'
EXECUTE rdt.rdtAddMsg 236038, 10, '236038^UnallocateFail',        'us_english', 1770, 0, '236038 Unallocate Failed'
EXECUTE rdt.rdtAddMsg 236039, 10, '236039^AllocateFail',          'us_english', 1770, 0, '236039 Allocate Failed'
EXECUTE rdt.rdtAddMsg 236040, 10, '236040^UpdTskFail',            'us_english', 1770, 0, '236040 Update TaskDetail Failed'
EXECUTE rdt.rdtAddMsg 236041, 10, '236041^UnallocateFail',        'us_english', 1770, 0, '236041 Unallocate Failed'
EXECUTE rdt.rdtAddMsg 236042, 10, '236042^UnallocateFail',        'us_english', 1770, 0, '236042 Allocate Failed'
EXECUTE rdt.rdtAddMsg 236043, 10, '236043^UpdTaskDetailFail',     'us_english', 1770, 0, '236043 Update Task Detail Failed'
EXECUTE rdt.rdtAddMsg 236044, 10, '236044^UpdTaskDetailFail',     'us_english', 1770, 0, '236044 Update Task Detail Failed'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 236001 AND 236050