--rdt_1764SwapUCC05
exec rdt.rdtDropMsg 163001 , 163050

execute rdt.rdtAddMsg 163001, 10, '63001^UCC scanned',      'us_english', 1764
execute rdt.rdtAddMsg 163002, 10, '63002^BadTaskDtlKey',    'us_english', 1764
execute rdt.rdtAddMsg 163003, 10, '63003^Not an UCC',       'us_english', 1764
execute rdt.rdtAddMsg 163004, 10, '63004^Multi SKU UCC',    'us_english', 1764
execute rdt.rdtAddMsg 163005, 10, '63005^Bad UCC Status',   'us_english', 1764
execute rdt.rdtAddMsg 163006, 10, '63006^UCCLOCNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 163007, 10, '63007^UCCIDNotMatch',    'us_english', 1764
execute rdt.rdtAddMsg 163008, 10, '63008^UCCQTYNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 163009, 10, '63009^UCCSKUNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 163010, 10, '63010^UCCL01NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 163011, 10, '63011^UCCL02NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 163012, 10, '63012^UCCL03NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 163013, 10, '63013^UCCL07NotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 163014, 10, '63014^UCCTookByOther',   'us_english', 1764
execute rdt.rdtAddMsg 163015, 10, '63015^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 163016, 10, '63016^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 163017, 10, '63017^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 163018, 10, '63018^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 163019, 10, '63019^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 163020, 10, '63020^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 163021, 10, '63021^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 163022, 10, '63022^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 163023, 10, '63023^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 163024, 10, '63024^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 163025, 10, '63025^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 163026, 10, '63026^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 163027, 10, '63027^UPDPackDtlFail',   'us_english', 1764


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 163001 AND 163050


