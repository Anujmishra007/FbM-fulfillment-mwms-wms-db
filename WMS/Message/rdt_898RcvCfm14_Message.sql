--rdt_898RcvCfm14
--fcr-1103
--231401 - 231450

execute rdt.rdtdropmsg 231401 , 231450

execute rdt.rdtAddMsg 231401, 10, '231401^UpdUDF01Fail',   'us_english', 898, 0, '231401 UpdUDF01Fail'
--231402 update receiptdetail failure (print sql error)
--231403 Insert receiptdetail failure (print sql error)


select * from rdt.rdtmsg(nolock) where message_id between 231401 and 231450