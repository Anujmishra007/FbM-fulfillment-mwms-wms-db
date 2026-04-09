-- rdt_1812ConUpdAU03 --  263601 - 263650
EXEC rdt.rdtDropMsg 263601, 263650

-- PackHeader
EXECUTE rdt.rdtAddMsg 263601, 10, '263601 InsPkHdrFail',          'us_english', 1812, 0, '263601 Insert PackHeader Failed'
EXECUTE rdt.rdtAddMsg 263602, 10, '263602 GetPkSlipFail',         'us_english', 1812, 0, '263602 Get PickSlipNo Failed'

-- PackDetail
EXECUTE rdt.rdtAddMsg 263603, 10, '263603 InsPkDtlFail',          'us_english', 1812, 0, '263603 Insert PackDetail Failed'
EXECUTE rdt.rdtAddMsg 263604, 10, '263604 UpdPkDtlFail',          'us_english', 1812, 0, '263604 Update PackDetail Failed'

-- PackDetailInfo
EXECUTE rdt.rdtAddMsg 263605, 10, '263605 InsPDInfoFail',         'us_english', 1812, 0, '263605 Insert PackDetailInfo Failed'
EXECUTE rdt.rdtAddMsg 263606, 10, '263606 UpdPDInfoFail',         'us_english', 1812, 0, '263606 Update PackDetailInfo Failed'

-- PackInfo
EXECUTE rdt.rdtAddMsg 263607, 10, '263607 InsPkInfoFail',         'us_english', 1812, 0, '263607 Insert PackInfo Failed'
EXECUTE rdt.rdtAddMsg 263608, 10, '263608 UpdPkInfoFail',         'us_english', 1812, 0, '263608 Update PackInfo Failed'

-- PickHeader
EXECUTE rdt.rdtAddMsg 263609, 10, '263609 InsPickHdrFail',        'us_english', 1812, 0, '263609 Insert PickHeader Failed'

-- LabelNo Generation
EXECUTE rdt.rdtAddMsg 263610, 10, '263610 GenLabelNoFail',        'us_english', 1812, 0, '263610 Generate LabelNo Failed'

-- Task Validation
EXECUTE rdt.rdtAddMsg 263611, 10, '263611 NoTask.ClosePL',        'us_english', 1812, 0, '263611 No Task Available. Close Pallet'
EXECUTE rdt.rdtAddMsg 263612, 10, '263612 OpenTaskExist',         'us_english', 1812, 0, '263612 Open Task Exists'

-- PickDetail
EXECUTE rdt.rdtAddMsg 263613, 10, '263613 UpdPickDtlFail',        'us_english', 1812, 0, '263613 Update PickDetail Failed'

-- TaskDetail
EXECUTE rdt.rdtAddMsg 263614, 10, '263614 UpdTaskDtlFail',        'us_english', 1812, 0, '263614 Update TaskDetail Failed'

-- Pack Confirm
EXECUTE rdt.rdtAddMsg 263615, 10, '263615 PackCfmFail',           'us_english', 1812, 0, '263615 Pack Confirm Failed'

-- Carrier Interface
EXECUTE rdt.rdtAddMsg 263616, 10, '263616 CarrierIntFail',        'us_english', 1812, 0, '263616 Carrier Interface Failed'

-- Assign Pack Label
EXECUTE rdt.rdtAddMsg 263617, 10, '263617 AsgnPkLblFail',         'us_english', 1812, 0, '263617 Assign Pack Label Failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263601 AND 263650
