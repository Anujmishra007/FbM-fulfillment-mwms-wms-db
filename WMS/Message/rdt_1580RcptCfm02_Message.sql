-- rdt_1580RcptCfm02
execute rdt.rdtDropMsg 101601 , 101650

execute rdt.rdtAddMsg 101601, 10, '01601^GET UCC FAIL',     'us_english'
execute rdt.rdtAddMsg 101602, 10, '01602^INSERT UCC ERR',   'us_english'
execute rdt.rdtAddMsg 101603, 10, '01603^LabelPrnterReq',   'us_english'
execute rdt.rdtAddMsg 101604, 10, '01604^DW NOT SETUP',     'us_english'
execute rdt.rdtAddMsg 101605, 10, '01605^TGETDB NOT SET',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 101601 and 101650