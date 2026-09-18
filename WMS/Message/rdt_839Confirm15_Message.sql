--rdt_839Confirm15
--FCR-9040
EXECUTE rdt.rdtdropmsg 255601 , 255630

EXECUTE rdt.rdtAddMsg 255601, 10, '255601 UpdPKDtlFail',                      'us_english', 839, 0, '255601 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255602, 10, '255602 UpdUCCFail',                        'us_english', 839, 0, '255602 Update UCC failed'
EXECUTE rdt.rdtAddMsg 255603, 10, '255603 UpdSNFail',                         'us_english', 839, 0, '255603 Update SerialNo failed'
EXECUTE rdt.rdtAddMsg 255604, 10, '255604 UpdPKDtlFail',                      'us_english', 839, 0, '255604 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255605, 10, '255605 UpdPKDtlFail',                      'us_english', 839, 0, '255605 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255606, 10, '255606 UpdUCCFail',                        'us_english', 839, 0, '255606 Update UCC failed'
EXECUTE rdt.rdtAddMsg 255607, 10, '255607 UpdPKDtlFail',                      'us_english', 839, 0, '255607 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255608, 10, '255608 UpdUCCFail',                        'us_english', 839, 0, '255608 Update UCC failed'
EXECUTE rdt.rdtAddMsg 255609, 10, '255609 UpdSNFail',                         'us_english', 839, 0, '255609 Update SerialNo failed'
EXECUTE rdt.rdtAddMsg 255610, 10, '255610 UpdSNFail',                         'us_english', 839, 0, '255610 Update SerialNo failed'
EXECUTE rdt.rdtAddMsg 255611, 10, '255611 UpdPKDtlFail',                      'us_english', 839, 0, '255611 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255612, 10, '255612 UpdPKDtlFail',                      'us_english', 839, 0, '255612 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255613, 10, '255613 GenKeyFail',                        'us_english', 839, 0, '255613 Generate key failed'
EXECUTE rdt.rdtAddMsg 255614, 10, '255614 InsPKDtlFail',                      'us_english', 839, 0, '255614 Insert pickdetail failed'
EXECUTE rdt.rdtAddMsg 255615, 10, '255615 Ins@tPickedKeysFail',               'us_english', 839, 0, '255615 Insert into @tPickedKeys failed'
EXECUTE rdt.rdtAddMsg 255616, 10, '255616 Ins@tSNMappingFail',                'us_english', 839, 0, '255616 Insert into @tSNMapping failed'
EXECUTE rdt.rdtAddMsg 255617, 10, '255617 Upd@tNewPKDtlFail',                 'us_english', 839, 0, '255617 Update @tNewPickDetail failed'
EXECUTE rdt.rdtAddMsg 255618, 10, '255618 Ins@tSNMappingFail',                'us_english', 839, 0, '255618 Insert into @tSNMapping failed'
EXECUTE rdt.rdtAddMsg 255619, 10, '255619 UpdUCCFail',                        'us_english', 839, 0, '255619 Update UCC failed'
EXECUTE rdt.rdtAddMsg 255620, 10, '255620 UpdPickLogFail',                    'us_english', 839, 0, '255620 Update rdtPickLog failed'
EXECUTE rdt.rdtAddMsg 255621, 10, '255621 GenKeyFail',                        'us_english', 839, 0, '255621 Generate key failed'
EXECUTE rdt.rdtAddMsg 255622, 10, '255622 InsPKDtlFail',                      'us_english', 839, 0, '255622 Insert pickdetail failed'
EXECUTE rdt.rdtAddMsg 255623, 10, '255623 UpdPKDtlFail',                      'us_english', 839, 0, '255623 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255624, 10, '255624 UpdPKDtlFail',                      'us_english', 839, 0, '255624 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255625, 10, '255625 DelPKDtlFail',                      'us_english', 839, 0, '255625 Delete PickDetail failed'
EXECUTE rdt.rdtAddMsg 255626, 10, '255626 InsPKDtlFail',                      'us_english', 839, 0, '255626 Insert PickDetail failed'
EXECUTE rdt.rdtAddMsg 255627, 10, '255627 UpdPKDtlFail',                      'us_english', 839, 0, '255627 Update PickDetail failed'
EXECUTE rdt.rdtAddMsg 255628, 10, '255628 UpdSNFail',                         'us_english', 839, 0, '255628 Update SerialNo failed'
EXECUTE rdt.rdtAddMsg 255629, 10, '255629 InsPickSNFail',                     'us_english', 839, 0, '255629 Insert PickSerialNo failed'
EXECUTE rdt.rdtAddMsg 255630, 10, '255630 DelPickLogFail',                    'us_english', 839, 0, '255630 Delete rdtPickLog failed'


SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 255601 AND 255630
