--rdt_1864SwapID01
exec rdt.rdtDropMsg 226701, 226750

execute rdt.rdtAddMsg 226701, 10, '226701ID not in LOC ', 'us_english', 1864
execute rdt.rdtAddMsg 226702, 10, '226702Get PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226703, 10, '226703nspg_GetKey   ', 'us_english', 1864
execute rdt.rdtAddMsg 226704, 10, '226704INS PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226705, 10, '226705INS RefKeyFail', 'us_english', 1864
execute rdt.rdtAddMsg 226706, 10, '226706INS PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226707, 10, '226707SKU QTY Diff  ', 'us_english', 1864
execute rdt.rdtAddMsg 226708, 10, '226708Get PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226709, 10, '226709nspg_GetKey   ', 'us_english', 1864
execute rdt.rdtAddMsg 226710, 10, '226710INS PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226711, 10, '226711INS RefKeyFail', 'us_english', 1864
execute rdt.rdtAddMsg 226712, 10, '226712INS PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226713, 10, '226713Get PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226714, 10, '226714nspg_GetKey   ', 'us_english', 1864
execute rdt.rdtAddMsg 226715, 10, '226715INS PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226716, 10, '226716INS RefKeyFail', 'us_english', 1864
execute rdt.rdtAddMsg 226717, 10, '226717INS PKDtl Fail', 'us_english', 1864
execute rdt.rdtAddMsg 226718, 10, '226718ID part alloc ', 'us_english', 1864
execute rdt.rdtAddMsg 226719, 10, '226719SKU QTY Diff  ', 'us_english', 1864
execute rdt.rdtAddMsg 226720, 10, '226720SKUQTYLOT Diff', 'us_english', 1864
execute rdt.rdtAddMsg 226721, 10, '226721SKUQTYLOT Diff', 'us_english', 1864

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 226701 AND 226750