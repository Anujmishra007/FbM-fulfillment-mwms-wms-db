--rdt_838ConfirmSP35
--execute rdt.rdtdropmsg 272651, 272700
execute rdt.rdtDropMsg 272651, 272700

execute rdt.rdtAddMsg 272651, 10, '272651^InsPHdrFail',        'us_english', 838, 0, '272651: Insert PackHeader failed'
execute rdt.rdtAddMsg 272652, 10, '272652^GenLabelNoFail',     'us_english', 838, 0, '272652: Generate LabelNo failed'
execute rdt.rdtAddMsg 272653, 10, '272653^GenLabelNoEmpty',    'us_english', 838, 0, '272653: Generated LabelNo is empty'
execute rdt.rdtAddMsg 272654, 10, '272654^UpdPackDtlFail',     'us_english', 838, 0, '272654: Update PackDetail failed'
execute rdt.rdtAddMsg 272655, 10, '272655^InsPackDtlFail',     'us_english', 838, 0, '272655: Insert PackDetail failed'
execute rdt.rdtAddMsg 272656, 10, '272656^UpdPackDtlFail',     'us_english', 838, 0, '272656: Update PackDetail failed'
execute rdt.rdtAddMsg 272657, 10, '272657^InsPackInfFail',     'us_english', 838, 0, '272657: Insert PackInfo failed'
execute rdt.rdtAddMsg 272658, 10, '272658^UpdPackInfFail',     'us_english', 838, 0, '272658: Update PackInfo failed'
execute rdt.rdtAddMsg 272659, 10, '272659^UpdUCCFail',         'us_english', 838, 0, '272659: Update UCC status failed'
execute rdt.rdtAddMsg 272660, 10, '272660^SNQTYNotTally',      'us_english', 838, 0, '272660: Serial no QTY does not tally'
execute rdt.rdtAddMsg 272661, 10, '272661^InsPackSNOFail',     'us_english', 838, 0, '272661: Insert PackSerialNo failed'
execute rdt.rdtAddMsg 272662, 10, '272662^SNOAlreadyScan',     'us_english', 838, 0, '272662: Serial no already scanned'
execute rdt.rdtAddMsg 272663, 10, '272663^DelTmpSNFail',       'us_english', 838, 0, '272663: Delete temp serial no failed'
execute rdt.rdtAddMsg 272664, 10, '272664^OffsetErrorQTY',     'us_english', 838, 0, '272664: Serial no offset error'
execute rdt.rdtAddMsg 272665, 10, '272665^OffsetErrorLog',     'us_english', 838, 0, '272665: Serial no offset error'
execute rdt.rdtAddMsg 272666, 10, '272666^InsPackSNOFail',     'us_english', 838, 0, '272666: Insert PackSerialNo failed'
execute rdt.rdtAddMsg 272667, 10, '272667^SNOAlreadyScan',     'us_english', 838, 0, '272667: Serial no already scanned'
execute rdt.rdtAddMsg 272668, 10, '272668^InsPDInfoFail',      'us_english', 838, 0, '272668: Insert PackDetailInfo failed'
execute rdt.rdtAddMsg 272669, 10, '272669^UpdPDInfoFail',      'us_english', 838, 0, '272669: Update PackDetailInfo failed'
EXECUTE rdt.rdtAddMsg 272670, 10, '272670^PackByFromDropIDNotConfig', 'us_english', 838, 0, '272670: PackByFromDropID not config'

-- PickDetail split logic error codes
execute rdt.rdtAddMsg 272671, 10, '272671^PackFromDropIDOff',  'us_english', 838, 0, '272671: PackByFromDropID not enabled'
execute rdt.rdtAddMsg 272672, 10, '272672^NoPDForPack',        'us_english', 838, 0, '272672: No PickDetail found for packing'
execute rdt.rdtAddMsg 272673, 10, '272673^PackQtyExceeds',     'us_english', 838, 0, '272673: Pack QTY exceeds available PickDetail QTY'
execute rdt.rdtAddMsg 272674, 10, '272674^UpdPDQtyFail',       'us_english', 838, 0, '272674: Update PickDetail QTY failed'
execute rdt.rdtAddMsg 272675, 10, '272675^MergePDQtyFail',     'us_english', 838, 0, '272675: Merge PickDetail QTY failed'
execute rdt.rdtAddMsg 272676, 10, '272676^UpdPDCaseIDFail',    'us_english', 838, 0, '272676: Update PickDetail CaseID failed'
execute rdt.rdtAddMsg 272677, 10, '272677^UpdPDQtyFail',       'us_english', 838, 0, '272677: Update PickDetail QTY failed'
execute rdt.rdtAddMsg 272678, 10, '272678^MergePDQtyFail',     'us_english', 838, 0, '272678: Merge PickDetail QTY failed'
execute rdt.rdtAddMsg 272679, 10, '272679^UpdPDQtyFail',       'us_english', 838, 0, '272679: Update PickDetail QTY failed'
execute rdt.rdtAddMsg 272680, 10, '272680^GenPDKeyFail',       'us_english', 838, 0, '272680: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 272681, 10, '272681^InsPDFail',          'us_english', 838, 0, '272681: Insert PickDetail failed'
execute rdt.rdtAddMsg 272682, 10, '272682^UpdPDStatusFail',    'us_english', 838, 0, '272682: Update PickDetail status failed'
execute rdt.rdtAddMsg 272683, 10, '272683^InsRefKeyFail',      'us_english', 838, 0, '272683: Insert RefKeyLookup failed'
execute rdt.rdtAddMsg 272684, 10, '272684^DelRefKeyFail',      'us_english', 838, 0, '272684: Delete RefKeyLookup failed'
execute rdt.rdtAddMsg 272685, 10, '272685^DelPDFail',          'us_english', 838, 0, '272685: Delete PickDetail failed'


select * from rdt.rdtmsg (nolock) where message_id between 272651 and 272700