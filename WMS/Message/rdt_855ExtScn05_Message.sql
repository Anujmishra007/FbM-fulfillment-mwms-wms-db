--FCR-13167 rdt_855ExtScn05 - Levis US PPA No Pre-Sort Flow
--Message IDs: 268651 - 268700

EXECUTE rdt.rdtDropMsg 268651, 268700

--SC1: Scan Carton (814 - reused)
EXECUTE rdt.rdtAddMsg 268651, 10, '268651CtnID Needed',   'us_english', 855, 0, '268651Carton ID needed'
EXECUTE rdt.rdtAddMsg 268652, 10, '268652Inv CartonID',   'us_english', 855, 0, '268652Invalid Carton ID'

--SC2: SKU Scan (6911)
EXECUTE rdt.rdtAddMsg 268653, 10, '268653Invalid SKU',    'us_english', 855, 0, '268653Invalid SKU'
EXECUTE rdt.rdtAddMsg 268654, 10, '268654SKU not found',  'us_english', 855, 0, '268654SKU not found'
EXECUTE rdt.rdtAddMsg 268655, 10, '268655SKU NotInCtn',   'us_english', 855, 0, '268655SKU not in carton'

--SC3/SC5: Options (6912/6914)
EXECUTE rdt.rdtAddMsg 268656, 10, '268656Invalid option', 'us_english', 855, 0, '268656Invalid option'

--WSSOECL TransmitLog/QCmd (Step 3 Enter)
EXECUTE rdt.rdtAddMsg 268661, 10, '268661TranLogFail',    'us_english', 855, 0, '268661TransmitLog Insert Failed'
EXECUTE rdt.rdtAddMsg 268662, 10, '268662QCmdFail',       'us_english', 855, 0, '268662QCmd Alert Failed'
EXECUTE rdt.rdtAddMsg 268663, 10, '268663PackComplete',   'us_english', 855, 0, '268663Packing Complete'

--Reserved for future use
EXECUTE rdt.rdtAddMsg 268657, 10, '268657QTY Exceed',     'us_english', 855, 0, '268657QTY exceeds expected'
EXECUTE rdt.rdtAddMsg 268658, 10, '268658Ctn Packed',     'us_english', 855, 0, '268658Carton already packed'
EXECUTE rdt.rdtAddMsg 268659, 10, '268659VAS Required',   'us_english', 855, 0, '268659VAS code required'
EXECUTE rdt.rdtAddMsg 268660, 10, '268660PrintLblFail',   'us_english', 855, 0, '268660Print label failed'

--RDTPPA Error Messages (FCR-13167)
EXECUTE rdt.rdtAddMsg 268664, 10, '268664PPAUpdFail',     'us_english', 855, 0, '268664RDTPPA Update Failed'
EXECUTE rdt.rdtAddMsg 268665, 10, '268665PPAInsFail',     'us_english', 855, 0, '268665RDTPPA Insert Failed'

--Archive Error Messages (FCR-13167)
EXECUTE rdt.rdtAddMsg 268666, 10, '268666PackDtlArcFail', 'us_english', 855, 0, '268666PackDetail Archive Failed'
EXECUTE rdt.rdtAddMsg 268667, 10, '268667PickDtlArcFail', 'us_english', 855, 0, '268667PickDetail Archive Failed'

--SUO Validation (FCR-13167)
EXECUTE rdt.rdtAddMsg 268668, 10, '268668SKU Completed', 'us_english', 855, 0, '268668SKU already scanned for all orders'

--ReferenceID Generation (FCR-13167 - moved from ExtUpd13/24)
EXECUTE rdt.rdtAddMsg 268669, 10, '268669GenRefIDFail', 'us_english', 855, 0, '268669Generate ReferenceID Failed'
EXECUTE rdt.rdtAddMsg 268670, 10, '268670UpdOrdInfoFl', 'us_english', 855, 0, '268670Update OrderInfo Failed'

--Verify messages
SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 268651 AND 268700
