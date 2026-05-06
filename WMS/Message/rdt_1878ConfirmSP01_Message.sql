--rdt_1878ConfirmSP01
--261201 - 261250

execute rdt.rdtDropMsg 261201, 261250

execute rdt.rdtAddMsg 261201 ,10, '261201^GenTransKeyFail',     'us_english', 1878, 0, '261201: Generate TransferKey Fail'
execute rdt.rdtAddMsg 261202 ,10, '261202^InsTransFail',        'us_english', 1878, 0, '261202: Insert transfer fail'
execute rdt.rdtAddMsg 261203 ,10, '261203^InsTransDetailFail',  'us_english', 1878, 0, '261203: Insert transfer detail fail'
execute rdt.rdtAddMsg 261204 ,10, '261204^FinalizeTransFail',   'us_english', 1878, 0, '261204: Finalize transfer fail'
execute rdt.rdtAddMsg 261205 ,10, '261205^InsPalletFail',       'us_english', 1878, 0, '261205: Insert Pallet fail'



select * from rdt.rdtmsg (nolock) where message_id between 261201 and 261250