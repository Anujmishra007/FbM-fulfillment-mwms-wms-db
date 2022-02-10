
-- ispLottableRule_Wrapper (range 61301 - 61325)
-- execute rdt.rdtDropMsg 61301, 61325
-- select * from rdt.rdtMsg (nolock) where message_id between 61301 and 61325

execute rdt.rdtAddMsg 61301, 10, '61301 Stored Proc Not Setup. (ispLottableRule_Wrapper)', 'us_english'
execute rdt.rdtAddMsg 61302, 10, '61302 Lottable Label Not Setup. (ispLottableRule_Wrapper)', 'us_english'
