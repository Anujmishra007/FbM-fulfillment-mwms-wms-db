--rdt.rdt_1770SwapID02
EXECUTE rdt.rdtdropmsg 236001, 236050

execute rdt.rdtAddMsg 236001, 10, '236001^Need ID       ',        'us_english', 1770
execute rdt.rdtAddMsg 236002, 10, '236002^BadTaskDtlKey ',        'us_english', 1770
execute rdt.rdtAddMsg 236003, 10, '236003^Invalid ID    ',        'us_english', 1770
execute rdt.rdtAddMsg 236004, 10, '236004^ID multi rec  ',        'us_english', 1770
execute rdt.rdtAddMsg 236005, 10, '236005^LOC not match ',        'us_english', 1770
execute rdt.rdtAddMsg 236006, 10, '236006^SKU not match ',        'us_english', 1770
execute rdt.rdtAddMsg 236007, 10, '236007^QTY not match ',        'us_english', 1770
execute rdt.rdtAddMsg 236008, 10, '236008^L04 not match ',        'us_english', 1770
execute rdt.rdtAddMsg 236009, 10, '236009^ID picked     ',        'us_english', 1770
execute rdt.rdtAddMsg 236010, 10, '236010^ID task taken ',        'us_english', 1770
execute rdt.rdtAddMsg 236011, 10, '236011^TaskOffsetErr ',        'us_english', 1770
execute rdt.rdtAddMsg 236012, 10, '236012^UPD Task Fail ',        'us_english', 1770
execute rdt.rdtAddMsg 236013, 10, '236013^UPD Task Fail ',        'us_english', 1770
execute rdt.rdtAddMsg 236014, 10, '236014^UPD Task Fail ',        'us_english', 1770
execute rdt.rdtAddMsg 236015, 10, '236015^TaskOffsetErr ',        'us_english', 1770
execute rdt.rdtAddMsg 236016, 10, '236016^UPD Task Fail ',        'us_english', 1770
execute rdt.rdtAddMsg 236017, 10, '236017^UPD Task Fail ',        'us_english', 1770
execute rdt.rdtAddMsg 236018, 10, '236018^NothingSwapped',        'us_english', 1770


SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 236001 AND 236050