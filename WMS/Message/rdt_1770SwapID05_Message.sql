--rdt.rdt_1770SwapID05
--FCR-3836
EXECUTE rdt.rdtdropmsg 236001, 236050

EXECUTE rdt.rdtAddMsg 236001, 10, '236001^Need ID       ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236002, 10, '236002^BadTaskDtlKey ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236003, 10, '236003^Invalid ID    ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236004, 10, '236004^ID multi rec  ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236005, 10, '236005^LOC not match ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236006, 10, '236006^SKU not match ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236007, 10, '236007^QTY not match ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236008, 10, '236008^L04 not match ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236009, 10, '236009^ID picked     ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236010, 10, '236010^ID task taken ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236011, 10, '236011^TaskOffsetErr ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236012, 10, '236012^UPD Task Fail ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236013, 10, '236013^UPD Task Fail ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236014, 10, '236014^UPD Task Fail ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236015, 10, '236015^TaskOffsetErr ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236016, 10, '236016^UPD Task Fail ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236017, 10, '236017^UPD Task Fail ',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236018, 10, '236018^NothingSwapped',        'us_english', 1770
EXECUTE rdt.rdtAddMsg 236019, 10, '236019^LocTypeNotMatch',       'us_english', 1770, 0, '236019 Racking Type Not Match'
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
EXECUTE rdt.rdtAddMsg 236035, 10, '236035^UnlockRPFFail',         'us_english', 1770
EXECUTE rdt.rdtAddMsg 236036, 10, '236036^UPDRPFTaskFail',        'us_english', 1770, 0, '236036 Update RPF Task Fail'
EXECUTE rdt.rdtAddMsg 236037, 10, '236037^SwapFPOnly',            'us_english', 1770, 0, '236037 Only allow to swap FP Pickmethod'
EXECUTE rdt.rdtAddMsg 236038, 10, '236038^IDLocked',              'us_english', 1770, 0, '236038 ID Locked, no task was generated'
EXECUTE rdt.rdtAddMsg 236039, 10, '236039^UpdTaskFail',           'us_english', 1770, 0, '236039 Update Task Fail'
EXECUTE rdt.rdtAddMsg 236040, 10, '236040^OnlySwapTask',          'us_english', 1770
EXECUTE rdt.rdtAddMsg 236041, 10, '236041^IDIsOnHold',            'us_english', 1770, 0, '236041 Scanned ID Is On Hold'
EXECUTE rdt.rdtAddMsg 236042, 10, '236042^UPD LLI Fail',          'us_english', 1770
EXECUTE rdt.rdtAddMsg 236043, 10, '236043^UPD LLI Fail',          'us_english', 1770
EXECUTE rdt.rdtAddMsg 236044, 10, '236044^NoPickDetailKey',       'us_english', 1770, 0, '236044 No Pick Detail Key'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 236001 AND 236050