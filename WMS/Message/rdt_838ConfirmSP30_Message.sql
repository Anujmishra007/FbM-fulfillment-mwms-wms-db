--rdt_838ConfirmSP30
--FCR-11193
exec rdt.rdtdropmsg 262601, 262650

-- Existing logic error codes (updated from 100xxx)
execute rdt.rdtAddMsg 262601, 10, '262601^InsPHdrFail',       'us_english', 838, 0, '262601: Insert PackHeader failed'
execute rdt.rdtAddMsg 262602, 10, '262602^GenLabelNoFail',    'us_english', 838, 0, '262602: Generate LabelNo failed'
execute rdt.rdtAddMsg 262603, 10, '262603^LabelNoEmpty',      'us_english', 838, 0, '262603: LabelNo is empty'
execute rdt.rdtAddMsg 262604, 10, '262604^InsPackDtlFail',    'us_english', 838, 0, '262604: Insert PackDetail failed'
execute rdt.rdtAddMsg 262605, 10, '262605^UpdPackDtlFail',    'us_english', 838, 0, '262605: Update PackDetail failed'
execute rdt.rdtAddMsg 262606, 10, '262606^InsPackInfFail',    'us_english', 838, 0, '262606: Insert PackInfo failed'
execute rdt.rdtAddMsg 262607, 10, '262607^UpdPackInfFail',    'us_english', 838, 0, '262607: Update PackInfo failed'
execute rdt.rdtAddMsg 262608, 10, '262608^UpdUCCFail',        'us_english', 838, 0, '262608: Update UCC failed'
execute rdt.rdtAddMsg 262609, 10, '262609^SNQtyNotTally',     'us_english', 838, 0, '262609: Serial No QTY not tally'
execute rdt.rdtAddMsg 262610, 10, '262610^InsPackSNOFail',    'us_english', 838, 0, '262610: Insert PackSerialNo failed'
execute rdt.rdtAddMsg 262611, 10, '262611^SNOAdyScanned',     'us_english', 838, 0, '262611: Serial No already scanned'
execute rdt.rdtAddMsg 262612, 10, '262612^DelTmpSNFail',      'us_english', 838, 0, '262612: Delete temp SerialNo failed'
execute rdt.rdtAddMsg 262613, 10, '262613^QtyOffsetErr',      'us_english', 838, 0, '262613: QTY offset error'
execute rdt.rdtAddMsg 262614, 10, '262614^QtyOffsetErr',      'us_english', 838, 0, '262614: QTY offset error'
execute rdt.rdtAddMsg 262615, 10, '262615^InsPackSNOFail',    'us_english', 838, 0, '262615: Insert PackSerialNo failed'
execute rdt.rdtAddMsg 262616, 10, '262616^SNOAdyScanned',     'us_english', 838, 0, '262616: Serial No already scanned'
execute rdt.rdtAddMsg 262617, 10, '262617^InsPDInfoFail',     'us_english', 838, 0, '262617: Insert PackDetailInfo failed'
execute rdt.rdtAddMsg 262618, 10, '262618^UpdPDInfoFail',     'us_english', 838, 0, '262618: Update PackDetailInfo failed'

-- New PickDetail split logic error codes
execute rdt.rdtAddMsg 262620, 10, '262620^PackQtyExceeds',    'us_english', 838, 0, '262620: Pack QTY exceeds available PickDetail QTY'
execute rdt.rdtAddMsg 262621, 10, '262621^NoPDForPack',       'us_english', 838, 0, '262621: No PickDetail found for packing'
execute rdt.rdtAddMsg 262622, 10, '262622^GenPDKeyFail',      'us_english', 838, 0, '262622: Generate PickDetailKey failed'
execute rdt.rdtAddMsg 262623, 10, '262623^InsPDFail',         'us_english', 838, 0, '262623: Insert PickDetail failed'
execute rdt.rdtAddMsg 262624, 10, '262624^UpdPDQtyFail',      'us_english', 838, 0, '262624: Update PickDetail QTY failed'
execute rdt.rdtAddMsg 262625, 10, '262625^MergePDQtyFail',    'us_english', 838, 0, '262625: Merge PickDetail QTY failed'
execute rdt.rdtAddMsg 262626, 10, '262626^InsRefKeyFail',     'us_english', 838, 0, '262626: Insert RefKeyLookup failed'
execute rdt.rdtAddMsg 262627, 10, '262627^DelPDFail',         'us_english', 838, 0, '262627: Delete PickDetail failed'
execute rdt.rdtAddMsg 262628, 10, '262628^DelRefKeyFail',     'us_english', 838, 0, '262628: Delete RefKeyLookup failed'

execute rdt.rdtAddMsg 262629, 10, '262629^UpdPackDtlFail',    'us_english', 838, 0, '262629: Update PackDetail failed'
execute rdt.rdtAddMsg 262630, 10, '262630^PackFromDropIDOff', 'us_english', 838, 0, '262630: Must enable PackByFromDropID config'
execute rdt.rdtAddMsg 262631, 10, '262631^UpdPackDtlFail',    'us_english', 838, 0, '262631: Update PackDetail failed'
execute rdt.rdtAddMsg 262632, 10, '262632^UpdPDQtyFail',      'us_english', 838, 0, '262632: Update PickDetail QTY failed'
execute rdt.rdtAddMsg 262633, 10, '262633^UpdPDQtyFail',      'us_english', 838, 0, '262633: Update PickDetail QTY failed'
execute rdt.rdtAddMsg 262634, 10, '262634^UpdPDQtyFail',      'us_english', 838, 0, '262634: Update PickDetail QTY failed'
execute rdt.rdtAddMsg 262635, 10, '262635^NoPKDFound',        'us_english', 838, 0, '262635: No more pickdetail found'

select * from rdt.rdtmsg (nolock) where message_id between 262601 and 262650
