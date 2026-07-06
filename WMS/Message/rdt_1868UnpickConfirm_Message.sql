-- rdt_1868UnpickConfirm
-- UWP-60041
EXECUTE rdt.rdtDropMsg 272601, 272650

EXECUTE rdt.rdtAddMsg 272601, 10, '272601^NoPickDetail',             'us_english', 1868, 0, '272601 No available PickDetail record exists'
EXECUTE rdt.rdtAddMsg 272602, 10, '272602^UpdPkdFail',               'us_english', 1868, 0, '272602 Fail to reduce PickDetail Qty'
EXECUTE rdt.rdtAddMsg 272603, 10, '272603^DelPkdFail',               'us_english', 1868, 0, '272603 Fail to delete PickDetailKey record'
EXECUTE rdt.rdtAddMsg 272604, 10, '272604^UpdPkInfoFail',            'us_english', 1868, 0, '272604 Fail to update ScanOutDate to NULL in PickingInfo'
EXECUTE rdt.rdtAddMsg 272605, 10, '272605^ExecRdtMoveFail',          'us_english', 1868, 0, '272605 Fail to move the item to the new location'
EXECUTE rdt.rdtAddMsg 272606, 10, '272606^GenKeyFail',               'us_english', 1868, 0, '272606 Fail to generate PickDetailKey'
EXECUTE rdt.rdtAddMsg 272607, 10, '272607^InsPkdFail',               'us_english', 1868, 0, '272607 Fail to insert new PickDetail record'
EXECUTE rdt.rdtAddMsg 272608, 10, '272608^UpdPkdIncrFail',           'us_english', 1868, 0, '272608 Fail to increase PickDetail Qty'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE Message_ID BETWEEN 272601 AND 272650	

