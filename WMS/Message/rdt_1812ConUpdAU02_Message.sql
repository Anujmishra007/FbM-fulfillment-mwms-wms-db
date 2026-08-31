-- rdt_1812ConUpdAU02 --  265651 - 265700
EXEC rdt.rdtDropMsg 265651, 265700

-- PackHeader
EXECUTE rdt.rdtAddMsg 265651, 10, '265651 InsPkHdrFail',          'us_english', 1812, 0, '265651 Insert PackHeader Failed'

-- Task Validation
EXECUTE rdt.rdtAddMsg 265652, 10, '265652 NoTask.ClosePL',        'us_english', 1812, 0, '265652 No Task. Close Pallet'
EXECUTE rdt.rdtAddMsg 265653, 10, '265653 OpenTaskExist',         'us_english', 1812, 0, '265653 Open Task Exists'

-- LabelNo Generation (Pallet/Piece Method)
EXECUTE rdt.rdtAddMsg 265654, 10, '265654 GenLabelNoFail',        'us_english', 1812, 0, '265654 Generate LabelNo Failed'
EXECUTE rdt.rdtAddMsg 265664, 10, '265664 GenLabelNoFail',        'us_english', 1812, 0, '265664 Generate LabelNo Failed'

-- LabelNo Generation (Case Method)
EXECUTE rdt.rdtAddMsg 265665, 10, '265665 GenLabelNoFail',        'us_english', 1812, 0, '265665 Generate LabelNo Failed'
EXECUTE rdt.rdtAddMsg 265666, 10, '265666 GenLabelNoFail',        'us_english', 1812, 0, '265666 Generate LabelNo Failed'

-- PackDetail (Pallet/Piece Method)
EXECUTE rdt.rdtAddMsg 265655, 10, '265655 InsPkDtlFail',          'us_english', 1812, 0, '265655 Insert PackDetail Failed'
EXECUTE rdt.rdtAddMsg 265656, 10, '265656 UpdPkDtlFail',          'us_english', 1812, 0, '265656 Update PackDetail Failed'

-- PackDetail (Case Method)
EXECUTE rdt.rdtAddMsg 265667, 10, '265667 InsPkDtlFail',          'us_english', 1812, 0, '265667 Insert PackDetail Failed'

-- PackDetailInfo (Pallet/Piece Method)
EXECUTE rdt.rdtAddMsg 265657, 10, '265657 InsPDInfoFail',         'us_english', 1812, 0, '265657 Insert PackDetailInfo Failed'
EXECUTE rdt.rdtAddMsg 265658, 10, '265658 UpdPDInfoFail',         'us_english', 1812, 0, '265658 Update PackDetailInfo Failed'

-- PackDetailInfo (Case Method)
EXECUTE rdt.rdtAddMsg 265668, 10, '265668 InsPDInfoFail',         'us_english', 1812, 0, '265668 Insert PackDetailInfo Failed'

-- PackInfo (Pallet/Piece Method)
EXECUTE rdt.rdtAddMsg 265659, 10, '265659 InsPkInfoFail',         'us_english', 1812, 0, '265659 Insert PackInfo Failed'
EXECUTE rdt.rdtAddMsg 265660, 10, '265660 UpdPkInfoFail',         'us_english', 1812, 0, '265660 Update PackInfo Failed'

-- PackInfo (Case Method)
EXECUTE rdt.rdtAddMsg 265669, 10, '265669 InsPkInfoFail',         'us_english', 1812, 0, '265669 Insert PackInfo Failed'

-- PickHeader
EXECUTE rdt.rdtAddMsg 265661, 10, '265661 InsPickHdrFail',        'us_english', 1812, 0, '265661 Insert PickHeader Failed'

-- Assign Pack Label
EXECUTE rdt.rdtAddMsg 265662, 10, '265662 AsgnPkLblFail',         'us_english', 1812, 0, '265662 Assign Pack Label Failed'

-- Pack Confirm
EXECUTE rdt.rdtAddMsg 265663, 10, '265663 PackCfmFail',           'us_english', 1812, 0, '265663 Pack Confirm Failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 265651 AND 265700
