-- rdt_605RcvCfm04
--255351 - 255400

rdt.rdtDropMsg 255351, 255400

execute rdt.rdtAddMsg 255351, 10, '255351^InsRcSNLogErr',   'us_english', 605, 0, '255351: Create ReceiptSerialNoLog Fail'
execute rdt.rdtAddMsg 255352, 10, '255352^SNNotFound',      'us_english', 605, 0, '255352: SerialNo Not Found'
execute rdt.rdtAddMsg 255353, 10, '255353^IDReceived',      'us_english', 605, 0, '255353: ToID was received'
execute rdt.rdtAddMsg 255354, 10, '255354^ASNConfirmed',    'us_english', 605, 0, '255354: ASN line was confirmed'
execute rdt.rdtAddMsg 255355, 10, '255355^NeedToLoc',       'us_english', 605, 0, '255355: Need toLoc'
execute rdt.rdtAddMsg 255356, 10, '255356^NewToIDEmpty',    'us_english', 605, 0, '255356: New ToID is empty'
execute rdt.rdtAddMsg 255357, 10, '255357^UpdRcptDtlFail',  'us_english', 605, 0, '255357: Update RcptDetail fail'

select * from rdt.rdtmsg with (nolock) where message_id between 255351 and 255400
