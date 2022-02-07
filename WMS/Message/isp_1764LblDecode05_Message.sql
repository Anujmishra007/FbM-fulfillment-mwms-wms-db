--isp_1764LblDecode05
execute rdt.rdtDropMsg 141901 , 141950	

execute rdt.rdtAddMsg 141901, 10, '41901^UCC scanned',      'us_english', 1764
execute rdt.rdtAddMsg 141902, 10, '41902^BadTaskDtlKey',    'us_english', 1764
execute rdt.rdtAddMsg 141903, 10, '41903^Not an UCC',       'us_english', 1764
execute rdt.rdtAddMsg 141904, 10, '41904^Multi SKU UCC',    'us_english', 1764
execute rdt.rdtAddMsg 141905, 10, '41905^Bad UCC Status',   'us_english', 1764
execute rdt.rdtAddMsg 141906, 10, '41906^UCCLOCNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 141907, 10, '41907^UCCIDNotMatch',    'us_english', 1764
execute rdt.rdtAddMsg 141908, 10, '41908^UCCQtyNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 141909, 10, '41909^UCCSKUNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 141910, 10, '41910^Bad LottaSetup',   'us_english', 1764
execute rdt.rdtAddMsg 141911, 10, '41911^UCCLotNotMatch',   'us_english', 1764
execute rdt.rdtAddMsg 141912, 10, '41912^UCCTookByOther',   'us_english', 1764
execute rdt.rdtAddMsg 141913, 10, '41913^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 141914, 10, '41914^PKDtl changed',    'us_english', 1764
execute rdt.rdtAddMsg 141915, 10, '41915^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 141916, 10, '41916^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 141917, 10, '41917^UPD UCC Fail',     'us_english', 1764
execute rdt.rdtAddMsg 141918, 10, '41918^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 141919, 10, '41919^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 141920, 10, '41920^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 141921, 10, '41921^UPD PKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 141922, 10, '41922^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 141923, 10, '41923^UPD TKDtl Fail',   'us_english', 1764
execute rdt.rdtAddMsg 141924, 10, '41924^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 141925, 10, '41925^UPDPackDtlFail',   'us_english', 1764
execute rdt.rdtAddMsg 141926, 10, '41926^No PKDtl Found',   'us_english', 1764

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 141901 AND 141950	


