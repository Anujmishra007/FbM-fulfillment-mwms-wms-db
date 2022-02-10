--rdt_1764SwapUCC04
execute rdt.rdtdropmsg 159751 , 159800

execute rdt.rdtAddMsg 159751, 10, '59751^UCC scanned',      'us_english', 1764
execute rdt.rdtAddMsg 159752, 10, '59752^BadTaskDtlKey',    'us_english', 1764
execute rdt.rdtAddMsg 159753, 10, '59753^Not an UCC',       'us_english', 1764
execute rdt.rdtAddMsg 159754, 10, '59754^Multi SKU UCC',    'us_english', 1764
execute rdt.rdtAddMsg 159755, 10, '59755^Bad UCC Status',   'us_english', 1764
execute rdt.rdtAddMsg 159756, 10, '59756^UCCLOCNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 159757, 10, '59757^UCCIDNotMatch',    'us_english', 1764
execute rdt.rdtAddMsg 159758, 10, '59758^UCCSKUNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 159759, 10, '59759^UCCQTYNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 159760, 10, '59760^Not match L',      'us_english', 1764
execute rdt.rdtAddMsg 159761, 10, '59761^UCCTookByOther',   'us_english', 1764
execute rdt.rdtAddMsg 159762, 10, '59762^UCCTookByOther',   'us_english', 1764
execute rdt.rdtAddMsg 159763, 10, '59763^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159764, 10, '59764^ActUCCTypeFail',   'us_english', 1764
execute rdt.rdtAddMsg 159765, 10, '59765^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159766, 10, '59766^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159767, 10, '59767^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159768, 10, '59768^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 159769, 10, '59769^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159770, 10, '59770^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 159771, 10, '59771^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 159772, 10, '59772^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159773, 10, '59773^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159774, 10, '59774^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 159775, 10, '59775^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159776, 10, '59776^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 159777, 10, '59777^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 159778, 10, '59778^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159779, 10, '59779^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 159780, 10, '59781^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159781, 10, '59781^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 159782, 10, '59782^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 159783, 10, '59783^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159784, 10, '59784^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159785, 10, '59785^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 159786, 10, '59786^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 159787, 10, '59787^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159788, 10, '59788^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159789, 10, '59789^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159790, 10, '59790^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 159791, 10, '59791^Data error',       'us_english', 1764

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 159751 AND 159800

