--rdt_1813ExtUpd03  (NYE018)
--254451 - 254500

execute rdt.rdtdropmsg 254451   , 254500

execute rdt.rdtAddMsg 254451 ,10, '254451^SerialNoUpdFail', 'us_english',1813, 0, '254451 : SerialNo update failed'
execute rdt.rdtAddMsg 254452 ,10, '254452^InvalidOption', 'us_english',1813, 0, '254452 : Invalid Option' -- rdt_1813ExtValid06

select * from rdt.rdtmsg (nolock) where message_id between 254451 and 254500