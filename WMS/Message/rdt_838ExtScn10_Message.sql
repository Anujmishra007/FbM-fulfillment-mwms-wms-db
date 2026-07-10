--rdt_838ExtScn10
--execute rdt.rdtdropmsg 272351, 272400
execute rdt.rdtDropMsg 272351, 272400

execute rdt.rdtAddMsg 272351, 10, '272351^DelMvListFail',        'us_english', 838, 0, '272351: Delete move list failed'
execute rdt.rdtAddMsg 272352, 10, '272352^UpdDevProfFail',       'us_english', 838, 0, '272352: Update DeviceProfile failed'
--execute rdt.rdtAddMsg 272353, 10, '272353^InMvListFailed',       'us_english', 838, 0, '272353: Insert move list failed (PTW to STGPTW - removed)'
execute rdt.rdtAddMsg 272354, 10, '272354^PackSTGNotDefined',    'us_english', 838, 0, '272354: Pack staging loc not defined'
execute rdt.rdtAddMsg 272355, 10, '272355^PackSTGNotExists',     'us_english', 838, 0, '272355: Pack staging location does not exist'
execute rdt.rdtAddMsg 272356, 10, '272356^InsertMvListFail',     'us_english', 838, 0, '272356: Insert move list failed'
execute rdt.rdtAddMsg 272357, 10, '272357^InvalidSetup',         'us_english', 838, 0, '272357: Incorrect setup'
execute rdt.rdtAddMsg 272358, 10, '272358^InvalidSetup',         'us_english', 838, 0, '272358: Incorrect setup'
execute rdt.rdtAddMsg 272359, 10, '272359^InvalidSetup',         'us_english', 838, 0, '272359: Incorrect setup'
execute rdt.rdtAddMsg 272360, 10, '272360^UpdRDTMobRecFail',     'us_english', 838, 0, '272360: Update RDTMOBREC failed'
--execute rdt.rdtAddMsg 272361, 10, '272361^UpdDevProfFail',       'us_english', 838, 0, '272361: Update DeviceProfile failed (STGPTW branch - removed)'
execute rdt.rdtAddMsg 272362, 10, '272362^NeedCartonType',        'us_english', 838, 0, '272362: Carton type is required'
execute rdt.rdtAddMsg 272363, 10, '272363^BadCartonType',         'us_english', 838, 0, '272363: Invalid carton type'
execute rdt.rdtAddMsg 272364, 10, '272364^InsPackInfoFail',       'us_english', 838, 0, '272364: Insert PackInfo failed'
execute rdt.rdtAddMsg 272365, 10, '272365^UpdPackInfoFail',       'us_english', 838, 0, '272365: Update PackInfo failed'
execute rdt.rdtAddMsg 272366, 10, '272366^OptionRequired',        'us_english', 838, 0, '272366: Option is required'
execute rdt.rdtAddMsg 272367, 10, '272367^InvalidOption',         'us_english', 838, 0, '272367: Invalid option, enter 1 or 9'
execute rdt.rdtAddMsg 272368, 10, '272368^RemPackQty>0',          'us_english', 838, 0, '272368: Must pack all items'

--FCR-14763 Add B2C Single logic
execute rdt.rdtAddMsg 272369, 10, '272369^NeedSKU',               'us_english', 838, 0, '272369: Need SKU'
execute rdt.rdtAddMsg 272370, 10, '272370^InvQty',                'us_english', 838, 0, '272370: Invalid Qty'
execute rdt.rdtAddMsg 272371, 10, '272371^InvQty',                'us_english', 838, 0, '272371: Invalid Qty'
execute rdt.rdtAddMsg 272372, 10, '272372^InvSKU',                'us_english', 838, 0, '272372: Invalid SKU'
execute rdt.rdtAddMsg 272373, 10, '272373^MultiSKUBarcod',        'us_english', 838, 0, '272373: Multiple SKU Barcod'
execute rdt.rdtAddMsg 272374, 10, '272374^PackDone',              'us_english', 838, 0, '272374: Label is pack done'
execute rdt.rdtAddMsg 272375, 10, '272375^InvSKU',                'us_english', 838, 0, '272375: SKU not found in PickSlipNo'
execute rdt.rdtAddMsg 272376, 10, '272376^NoPackInfo',            'us_english', 838, 0, '272376: No PackInfo record found'
execute rdt.rdtAddMsg 272377, 10, '272377^SKUPacked',             'us_english', 838, 0, '272377: SKU is packed'
execute rdt.rdtAddMsg 272378, 10, '272378^InvSKU',                'us_english', 838, 0, '272378: SKU not found in PickSlipNo'
execute rdt.rdtAddMsg 272379, 10, '272379^NoPackInfo',            'us_english', 838, 0, '272379: No PackInfo record found'
execute rdt.rdtAddMsg 272380, 10, '272380^SKUPacked',             'us_english', 838, 0, '272380: SKU is packed'
execute rdt.rdtAddMsg 272381, 10, '272381^UpdPackDetailFail',     'us_english', 838, 0, '272381: Increase PackDetail Qty failed'
execute rdt.rdtAddMsg 272382, 10, '272382^ExecCfmSPFail',         'us_english', 838, 0, '272382: Execute Confirm SP failed'
execute rdt.rdtAddMsg 272383, 10, '272383^ExecCfmSPFail',         'us_english', 838, 0, '272383: Execute Confirm SP failed'

select * from rdt.rdtmsg (nolock) where message_id between 272351 and 272400
