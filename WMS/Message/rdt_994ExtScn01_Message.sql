--rdt_994ExtScn01
--execute rdt.rdtdropmsg 280801, 280850
execute rdt.rdtDropMsg 280801, 280850


execute rdt.rdtAddMsg 280801, 10, '280801^MoveToPackFail',       'us_english', 994, 0, '280801: Move to pack failed'
execute rdt.rdtAddMsg 280802, 10, '280802^PSNOIsEmpty',          'us_english', 994, 0, '280802: PickSlipNo is empty'
--execute rdt.rdtAddMsg 280803, 10, '280803^PackSTGNotDefined',    'us_english', 994, 0, '280803: Pack staging loc not defined'        --moved to rdt_944ExtScn01_MoveToPack (281001)
--execute rdt.rdtAddMsg 280804, 10, '280804^PackSTGNotExists',     'us_english', 994, 0, '280804: Pack staging location does not exist' --moved to rdt_944ExtScn01_MoveToPack (281002)
--execute rdt.rdtAddMsg 280805, 10, '280805^InsertMvListFail',     'us_english', 994, 0, '280805: Insert move list failed'              --moved to rdt_944ExtScn01_MoveToPack (281003)
--execute rdt.rdtAddMsg 280806, 10, '280806^InvalidSetup',         'us_english', 994, 0, '280806: Incorrect setup'                      --moved to rdt_944ExtScn01_MoveToPack (281005)
--execute rdt.rdtAddMsg 280807, 10, '280807^InvalidSetup',         'us_english', 994, 0, '280807: Incorrect setup'                      --moved to rdt_944ExtScn01_MoveToPack (281006)
--execute rdt.rdtAddMsg 280808, 10, '280808^InvalidSetup',         'us_english', 994, 0, '280808: Incorrect setup'                      --moved to rdt_944ExtScn01_MoveToPack (281007)
execute rdt.rdtAddMsg 280809, 10, '280809^UpdRDTMobRecFail',     'us_english', 994, 0, '280809: Update RDTMOBREC failed'
execute rdt.rdtAddMsg 280810, 10, '280810^NeedCartonType',        'us_english', 994, 0, '280810: Carton type is required'
execute rdt.rdtAddMsg 280811, 10, '280811^BadCartonType',         'us_english', 994, 0, '280811: Invalid carton type'
execute rdt.rdtAddMsg 280812, 10, '280812^InsPackInfoFail',       'us_english', 994, 0, '280812: Insert PackInfo failed'
execute rdt.rdtAddMsg 280813, 10, '280813^UpdPackInfoFail',       'us_english', 994, 0, '280813: Update PackInfo failed'
execute rdt.rdtAddMsg 280814, 10, '280814^OptionRequired',        'us_english', 994, 0, '280814: Option is required'
execute rdt.rdtAddMsg 280815, 10, '280815^InvalidOption',         'us_english', 994, 0, '280815: Invalid option, enter 1 or 9'
execute rdt.rdtAddMsg 280816, 10, '280816^RemPackQty>0',          'us_english', 994, 0, '280816: Must pack all items'
execute rdt.rdtAddMsg 280817, 10, '280817^NeedSKU',               'us_english', 994, 0, '280817: Need SKU'
execute rdt.rdtAddMsg 280818, 10, '280818^InvQty',                'us_english', 994, 0, '280818: Invalid Qty'
execute rdt.rdtAddMsg 280819, 10, '280819^InvQty',                'us_english', 994, 0, '280819: Invalid Qty'
execute rdt.rdtAddMsg 280820, 10, '280820^InvSKU',                'us_english', 994, 0, '280820: Invalid SKU'
execute rdt.rdtAddMsg 280821, 10, '280821^MultiSKUBarcod',        'us_english', 994, 0, '280821: Multiple SKU Barcod'
execute rdt.rdtAddMsg 280822, 10, '280822^PackDone',              'us_english', 994, 0, '280822: Label is pack done'
execute rdt.rdtAddMsg 280823, 10, '280823^InvSKU',                'us_english', 994, 0, '280823: SKU not found in PickSlipNo'
execute rdt.rdtAddMsg 280824, 10, '280824^NoPackInfo',            'us_english', 994, 0, '280824: No PackInfo record found'
execute rdt.rdtAddMsg 280825, 10, '280825^SKUPacked',             'us_english', 994, 0, '280825: SKU is packed'
execute rdt.rdtAddMsg 280826, 10, '280826^InvSKU',                'us_english', 994, 0, '280826: SKU not found in PickSlipNo'
execute rdt.rdtAddMsg 280827, 10, '280827^NoPackInfo',            'us_english', 994, 0, '280827: No PackInfo record found'
execute rdt.rdtAddMsg 280828, 10, '280828^SKUPacked',             'us_english', 994, 0, '280828: SKU is packed'
--execute rdt.rdtAddMsg 280829, 10, '280829^UpdPackDetailFail',     'us_english', 994, 0, '280829: Increase PackDetail Qty failed'
execute rdt.rdtAddMsg 280830, 10, '280830^ExecCfmSPFail',         'us_english', 994, 0, '280830: Execute Confirm SP failed'
--execute rdt.rdtAddMsg 280831, 10, '280831^ExecCfmSPFail',         'us_english', 994, 0, '280831: Execute Confirm SP failed'

execute rdt.rdtAddMsg 280833, 10, '280833^InsPackDtlFail',        'us_english', 994, 0, '280833: Insert PackDetail failed'

--FCR-16295
execute rdt.rdtAddMsg 280832, 10, '280832^Ord&LoadEmpty',         'us_english', 994, 0, '280832: OrderKey and LoadKey both empty'
execute rdt.rdtAddMsg 280834, 10, '280834^WaveKeyEmpty',          'us_english', 994, 0, '280834: WaveKey is empty'
--execute rdt.rdtAddMsg 280835, 10, '280835^PKDNotFound',           'us_english', 994, 0, '280835: PickDetail Not found'    --moved to rdt_944ExtScn01_MoveToPack (281004)
execute rdt.rdtAddMsg 280836, 10, '280836^B2CSingleNotSupported', 'us_english', 994, 0, '280836: B2C Single not supported'

select * from rdt.rdtmsg (nolock) where message_id between 280801 and 280850
