--rdt_ClusterPickCfm19
execute rdt.rdtDropMsg 168951 , 169000

execute rdt.rdtAddMsg 168951, 10, '168951PickSlip req  ',   'us_english', 1620
execute rdt.rdtAddMsg 168952, 10, '168952NeedLottable02',   'us_english', 1620
execute rdt.rdtAddMsg 168953, 10, '168953Sku Not In ORD',   'us_english', 1620
execute rdt.rdtAddMsg 168954, 10, '168954 L02 Not Match',   'us_english', 1620
execute rdt.rdtAddMsg 168955, 10, '168955 Swap Lot Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168956, 10, '168956 Swap Lot Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168957, 10, '168957 UPDPKDET Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168958, 10, '168958 Swap Lot Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168959, 10, '168959 Swap Lot Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168600, 10, '168600OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168601, 10, '168601OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168602, 10, '168602OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168603, 10, '168603 GetDetKeyFail',   'us_english', 1620
execute rdt.rdtAddMsg 168604, 10, '168604 Ins PDtl Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168605, 10, '168605 INS RefKeyFail',  'us_english', 1620
execute rdt.rdtAddMsg 168606, 10, '168606OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168607, 10, '168607OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168608, 10, '168608SKU Overpacked',   'us_english', 1620
execute rdt.rdtAddMsg 168609, 10, '168609 InsPHdrFail  ',   'us_english', 1620
execute rdt.rdtAddMsg 168610, 10, '168610 GenLabelFail ',   'us_english', 1620
execute rdt.rdtAddMsg 168611, 10, '168611InsPackDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168612, 10, '168612InsPackDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168613, 10, '168613UpdPackDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168614, 10, '168614UpdCaseID Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168615, 10, '168615 UPDPKLockFail',   'us_english', 1620
execute rdt.rdtAddMsg 168616, 10, '168616OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168617, 10, '168617SpoolNot Setup',   'us_english', 1620
execute rdt.rdtAddMsg 168618, 10, '168618INS QTask Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168619, 10, '168619INS QTask Fail',   'us_english', 1620
execute rdt.rdtAddMsg 168620, 10, '168620No Lot To Swap',   'us_english', 1620
execute rdt.rdtAddMsg 168621, 10, '168621Upd PickLot Er',   'us_english', 1620
execute rdt.rdtAddMsg 168622, 10, '168622Upd PickLot Er',   'us_english', 1620
execute rdt.rdtAddMsg 168623, 10, '168623UpdPickDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168624, 10, '168624UpdPickDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 168625, 10, '168625UpdPickDtlFail',   'us_english', 1620


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 168951 AND 169000