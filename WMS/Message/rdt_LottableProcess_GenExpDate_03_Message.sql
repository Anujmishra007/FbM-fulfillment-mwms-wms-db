--rdt_LottableProcess_GenExpDate_03
execute rdt.rdtDropMsg 161551, 161600

execute rdt.rdtAddMsg 161551, 10, '61551^Invalid Date  ', 'us_english', 598

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 161551 AND 161600
