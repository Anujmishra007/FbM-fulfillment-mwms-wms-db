--rdt_1764SwapUCC13_Message
EXEC rdt.rdtdropmsg 266801, 266850

EXECUTE rdt.rdtAddMsg 266801, 10, '266801^UCC scanned',         'us_english', 1764, 0, '266801 UCC scanned'
EXECUTE rdt.rdtAddMsg 266802, 10, '266802^BadTaskDtlKey',       'us_english', 1764, 0, '266802 BadTaskDtlKey'
EXECUTE rdt.rdtAddMsg 266803, 10, '266803^Not an UCC',          'us_english', 1764, 0, '266803 Not an UCC'
EXECUTE rdt.rdtAddMsg 266804, 10, '266804^Multi SKU UCC',       'us_english', 1764, 0, '266804 Multi SKU UCC'
EXECUTE rdt.rdtAddMsg 266805, 10, '266805^Bad UCC Status',      'us_english', 1764, 0, '266805 Bad UCC Status'
EXECUTE rdt.rdtAddMsg 266806, 10, '266806^UCCLOCNotMatch',      'us_english', 1764, 0, '266806 UCCLOCNotMatch'
EXECUTE rdt.rdtAddMsg 266807, 10, '266807^UCCIDNotMatch',       'us_english', 1764, 0, '266807 UCCIDNotMatch'
EXECUTE rdt.rdtAddMsg 266808, 10, '266808^UCCSKUNotMatch',      'us_english', 1764, 0, '266808 UCCSKUNotMatch'
EXECUTE rdt.rdtAddMsg 266809, 10, '266809^UCCQTYNotMatch',      'us_english', 1764, 0, '266809 UCCQTYNotMatch'
EXECUTE rdt.rdtAddMsg 266810, 10, '266810^Not match L',         'us_english', 1764, 0, '266810 Not match L'
EXECUTE rdt.rdtAddMsg 266811, 10, '266811^UCCTookByOther',      'us_english', 1764, 0, '266811 UCCTookByOther'
EXECUTE rdt.rdtAddMsg 266812, 10, '266812^UPD PKDtl Fail',      'us_english', 1764, 0, '266812 UPD PKDtl Fail'
EXECUTE rdt.rdtAddMsg 266813, 10, '266813^ActUCCTypeFail',      'us_english', 1764, 0, '266813 ActUCCTypeFail'
EXECUTE rdt.rdtAddMsg 266814, 10, '266814^UPD TKDtl Fail',      'us_english', 1764, 0, '266814 UPD TKDtl Fail'
EXECUTE rdt.rdtAddMsg 266815, 10, '266815^PKDtl changed',       'us_english', 1764, 0, '266815 PKDtl changed'
EXECUTE rdt.rdtAddMsg 266816, 10, '266816^UPD UCC Fail',        'us_english', 1764, 0, '266816 UPD UCC Fail'
EXECUTE rdt.rdtAddMsg 266817, 10, '266817^MissingPackDtl',      'us_english', 1764, 0, '266817 MissingPackDtl'
EXECUTE rdt.rdtAddMsg 266818, 10, '266818^DUP PackDtl',         'us_english', 1764, 0, '266818 DUP PackDtl'
EXECUTE rdt.rdtAddMsg 266819, 10, '266819^UPDLLIFail',          'us_english', 1764, 0, '266819 UPDLLIFail'
EXECUTE rdt.rdtAddMsg 266820, 10, '266820^Data error',          'us_english', 1764, 0, '266820 Data error'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 266801 AND 266850
