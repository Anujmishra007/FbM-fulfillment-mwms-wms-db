--rdt_ClusterPickCfm15
execute rdt.rdtDropMsg 152001 , 152050

execute rdt.rdtAddMsg 152001, 10, '52001^PickSlip req',     'us_english', 1620
execute rdt.rdtAddMsg 152002, 10, '52002^NeedLottable02',   'us_english', 1620
execute rdt.rdtAddMsg 152003, 10, '52003^Sku Not In ORD',   'us_english', 1620
execute rdt.rdtAddMsg 152004, 10, '52004^L02 Not Match',    'us_english', 1620
execute rdt.rdtAddMsg 152005, 10, '52005^Swap Lot Fail',    'us_english', 1620
execute rdt.rdtAddMsg 152006, 10, '52006^Swap Lot Fail',    'us_english', 1620
execute rdt.rdtAddMsg 152007, 10, '52007^UPDPKDET Fail',    'us_english', 1620
execute rdt.rdtAddMsg 152008, 10, '52008^Swap Lot Fail',    'us_english', 1620
execute rdt.rdtAddMsg 152009, 10, '52009^Swap Lot Fail',    'us_english', 1620
execute rdt.rdtAddMsg 152010, 10, '52010^OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152011, 10, '52011^OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152012, 10, '52012^OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152013, 10, '52013^GetDetKeyFail',    'us_english', 1620
execute rdt.rdtAddMsg 152014, 10, '52014^Ins PDtl Fail',    'us_english', 1620
execute rdt.rdtAddMsg 152015, 10, '52015^INS RefKeyFail',   'us_english', 1620
execute rdt.rdtAddMsg 152016, 10, '52016^OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152017, 10, '52017^OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152018, 10, '52018^SKU Overpacked',   'us_english', 1620
execute rdt.rdtAddMsg 152019, 10, '52019^InsPHdrFail',      'us_english', 1620
execute rdt.rdtAddMsg 152020, 10, '52020^GenLabelFail',     'us_english', 1620
execute rdt.rdtAddMsg 152021, 10, '52021^InsPackDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152022, 10, '52022^InsPackDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152023, 10, '52023^UpdPackDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152024, 10, '52024^UpdCaseID Fail',   'us_english', 1620
execute rdt.rdtAddMsg 152025, 10, '52025^UPDPKLockFail',    'us_english', 1620
execute rdt.rdtAddMsg 152026, 10, '52026^OffSetPDtlFail',   'us_english', 1620
execute rdt.rdtAddMsg 152027, 10, '52027^SpoolNot Setup',   'us_english', 1620
execute rdt.rdtAddMsg 152028, 10, '52028^INS QTask Fail',   'us_english', 1620
execute rdt.rdtAddMsg 152029, 10, '52029^INS QTask Fail',   'us_english', 1620
execute rdt.rdtAddMsg 152030, 10, '52030^No Lot To Swap',   'us_english', 1620
execute rdt.rdtAddMsg 152031, 10, '52031^Upd PickLot Er',   'us_english', 1620
execute rdt.rdtAddMsg 152032, 10, '52032^Upd PickLot Er',   'us_english', 1620
execute rdt.rdtAddMsg 152033, 10, '52033^UpdPickDtlFail',   'us_english', 1620


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 152001 AND 152050