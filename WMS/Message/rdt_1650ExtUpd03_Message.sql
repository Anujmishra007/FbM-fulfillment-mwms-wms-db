--rdt_1650ExtUpd03
--FCR-574
execute rdt.rdtdropmsg 219501 , 219550

execute rdt.rdtAddMsg 219501, 10, '219501ExtUpd01Miss',     'us_english', 1650, 0, '219501 1650ExtUpd01 is Missing'
execute rdt.rdtAddMsg 219502, 10, '219502DropPalletFail',   'us_english', 1650, 0, '219502 Drop Pallet Fail'
execute rdt.rdtAddMsg 219503, 10, '219503ExtUpd01Miss',     'us_english', 1650, 0, '219503 1650ExtUpd01 is Missing'
execute rdt.rdtAddMsg 219504, 10, '219504CloseTruckFail',   'us_english', 1650, 0, '219504 Close truck fail'

select * from rdt.rdtmsg WITH(NOLOCK) where message_id between 219501 and 219550

