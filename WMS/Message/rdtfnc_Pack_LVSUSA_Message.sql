
--FCR-946
exec rdt.rdtdropmsg 226451 , 226500

execute rdt.rdtAddMsg 226451, 10, '226451NeedCart', 'us_english', 993, 0, '226451 Carton ID Required'
execute rdt.rdtAddMsg 226452, 10, '226452CartNotExist', 'us_english', 993, 0, '226452 Carton Not Exist'
execute rdt.rdtAddMsg 226453, 10, '226453ReopenPKHFail', 'us_english', 993, 0, '226453 Failed to Reopen PKH'
execute rdt.rdtAddMsg 226454, 10, '226454NeedOption', 'us_english', 993, 0, '226454 Option Required'
execute rdt.rdtAddMsg 226455, 10, '226455InvalidOption', 'us_english', 993, 0, '226455 Invalid Option'
execute rdt.rdtAddMsg 226456, 10, '226456OptDisabled', 'us_english', 993, 0, '226456 The Option Disabled'
execute rdt.rdtAddMsg 226457, 10, '226457CantEditUCC', 'us_english', 993, 0, '226457 Can Not Edit UCC'
execute rdt.rdtAddMsg 226458, 10, '226458FromLabelReq', 'us_english', 993, 0, '226458 From Carton ID Required'
execute rdt.rdtAddMsg 226459, 10, '226459FromLabelNoExist', 'us_english', 993, 0, '226459 From Carton ID Not Exist'
execute rdt.rdtAddMsg 226460, 10, '226460InvalidSKU', 'us_english', 993, 0, '226460 Invalid SKU'
execute rdt.rdtAddMsg 226461, 10, '226461MultiSKU', 'us_english', 993, 0, '226461 Multiple SKU Barcode'
execute rdt.rdtAddMsg 226462, 10, '226462InvalidQty', 'us_english', 993, 0, '226462 Invalid Qty'
execute rdt.rdtAddMsg 226463, 10, '226463InvalidQty', 'us_english', 993, 0, '226463 Invalid Qty'
execute rdt.rdtAddMsg 226464, 10, '226464UpdPackInfoFail', 'us_english', 993, 0, '226464 Fail to Master Label No PackInfo'
execute rdt.rdtAddMsg 226465, 10, '226465CartTypeReqired', 'us_english', 993, 0, '226465 Carton Type Required'
execute rdt.rdtAddMsg 226466, 10, '226466InvCartonType', 'us_english', 993, 0, '226466 Invalid Carton Type'
execute rdt.rdtAddMsg 226467, 10, '226467OptionRequired', 'us_english', 993, 0, '226467 Option Required'
execute rdt.rdtAddMsg 226468, 10, '226468InvalidOption', 'us_english', 993, 0, '226468 Invalid Option'
execute rdt.rdtAddMsg 226469, 10, '226469MustSetCartType', 'us_english', 993, 0, '226469 Must Input New Carton Type'
execute rdt.rdtAddMsg 226470, 10, '226470UpdCartWgtFail', 'us_english', 993, 0, '226470 Fail to Update Carton Weight'
execute rdt.rdtAddMsg 226471, 10, '226471UpdPackInfoFail', 'us_english', 993, 0, '226471 Fail to Master Label No PackInfo'
execute rdt.rdtAddMsg 226472, 10, '226472UpdCartWgtFail', 'us_english', 993, 0, '226472 Fail to Update Carton Weight'
execute rdt.rdtAddMsg 226473, 10, '226473UpdPackInfoFail', 'us_english', 993, 0, '226473 Fail to New Label No PackInfo'
execute rdt.rdtAddMsg 226474, 10, '226474UpdCartWgtFail', 'us_english', 993, 0, '226474 Fail to Update Carton Weight'
execute rdt.rdtAddMsg 226475, 10, '226475LabelNoEmpty', 'us_english', 993, 0, '226475 Label No Is Empty'



select * from rdt.rdtmsg (nolock) where message_id between 226451 AND 226500