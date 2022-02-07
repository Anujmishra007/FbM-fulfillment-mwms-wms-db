





SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '179251' AND '179300'


--rdt_598RcvCfm04
EXEC rdt.rdtDropMsg 179251, 179300

execute rdt.rdtAddMsg 179251, 10, '179251 Offset error  ',   'us_english', 598
execute rdt.rdtAddMsg 179252, 10, '179252 Upd RcptD Err ',   'us_english', 598