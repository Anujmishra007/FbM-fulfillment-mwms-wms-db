--rdt_LottableProcess_RIMVal
execute rdt.rdtDropMsg 280501, 280550

execute rdt.rdtAddMsg 280501, 10, '280501^Lottable04 req', 'us_english', 600, 0, '280501: Lottable4 is required'
execute rdt.rdtAddMsg 280502, 10, '280502^Prod close exp', 'us_english', 600, 0, '280502: Product close to expiry'

select * from rdt.rdtmsg (nolock) where message_id between 280501 and 280550
