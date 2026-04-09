-- rdt_1812ConUpdAU01 --  263551 - 263600
EXEC rdt.rdtDropMsg 263551, 263600

-- PackHeader
EXECUTE rdt.rdtAddMsg 263551, 10, '263551 InsPkHdrFail',          'us_english', 1812, 0, '263551 Insert PackHeader Failed'
EXECUTE rdt.rdtAddMsg 263552, 10, '263552 GetPkSlipFail',         'us_english', 1812, 0, '263552 Get PickSlipNo Failed'

-- PackDetail
EXECUTE rdt.rdtAddMsg 263553, 10, '263553 InsPkDtlFail',          'us_english', 1812, 0, '263553 Insert PackDetail Failed'
EXECUTE rdt.rdtAddMsg 263554, 10, '263554 UpdPkDtlFail',          'us_english', 1812, 0, '263554 Update PackDetail Failed'

-- PackDetailInfo
EXECUTE rdt.rdtAddMsg 263555, 10, '263555 InsPDInfoFail',         'us_english', 1812, 0, '263555 Insert PackDetailInfo Failed'
EXECUTE rdt.rdtAddMsg 263556, 10, '263556 UpdPDInfoFail',         'us_english', 1812, 0, '263556 Update PackDetailInfo Failed'

-- PackInfo
EXECUTE rdt.rdtAddMsg 263557, 10, '263557 InsPkInfoFail',         'us_english', 1812, 0, '263557 Insert PackInfo Failed'
EXECUTE rdt.rdtAddMsg 263558, 10, '263558 UpdPkInfoFail',         'us_english', 1812, 0, '263558 Update PackInfo Failed'

-- PickHeader
EXECUTE rdt.rdtAddMsg 263559, 10, '263559 InsPickHdrFail',        'us_english', 1812, 0, '263559 Insert PickHeader Failed'

-- LabelNo Generation
EXECUTE rdt.rdtAddMsg 263560, 10, '263560 GenLabelNoFail',        'us_english', 1812, 0, '263560 Generate LabelNo Failed'

-- Task Validation
EXECUTE rdt.rdtAddMsg 263561, 10, '263561 NoTask.ClosePL',        'us_english', 1812, 0, '263561 No Task Available. Close Pallet'
EXECUTE rdt.rdtAddMsg 263562, 10, '263562 OpenTaskExist',         'us_english', 1812, 0, '263562 Open Task Exists'

-- PickDetail
EXECUTE rdt.rdtAddMsg 263563, 10, '263563 UpdPickDtlFail',        'us_english', 1812, 0, '263563 Update PickDetail Failed'

-- TaskDetail
EXECUTE rdt.rdtAddMsg 263564, 10, '263564 UpdTaskDtlFail',        'us_english', 1812, 0, '263564 Update TaskDetail Failed'

-- Pack Confirm
EXECUTE rdt.rdtAddMsg 263565, 10, '263565 PackCfmFail',           'us_english', 1812, 0, '263565 Pack Confirm Failed'

-- Carrier Interface
EXECUTE rdt.rdtAddMsg 263566, 10, '263566 CarrierIntFail',        'us_english', 1812, 0, '263566 Carrier Interface Failed'

-- Assign Pack Label
EXECUTE rdt.rdtAddMsg 263567, 10, '263567 AsgnPkLblFail',         'us_english', 1812, 0, '263567 Assign Pack Label Failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263551 AND 263600
