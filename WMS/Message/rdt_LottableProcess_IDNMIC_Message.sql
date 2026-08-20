--rdt_LottableProcess_IDNMIC
--execute rdt.rdtdropmsg 278701 - 278750
execute rdt.rdtDropMsg 278701, 278750

execute rdt.rdtAddMsg 278701, 10, '278701^UpdateReceiptDetailFailed', 'us_english', 0, 0, '278701: Update ReceiptDetail Failed'

select * from rdt.rdtmsg (nolock) where message_id between 278701 and 278750
