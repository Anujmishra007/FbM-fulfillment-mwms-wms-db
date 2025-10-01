-- rdt_598DecodeSN01
execute rdt.rdtDropMsg 241601, 241650

execute rdt.rdtAddMsg 241601, 10, '241601INSLogFail', 'us_english', 598 
execute rdt.rdtAddMsg 241602, 10, '241602BadSNOsetup', 'us_english', 598 
execute rdt.rdtAddMsg 241603, 10, '241603BadSNOsetup', 'us_english', 598 
execute rdt.rdtAddMsg 241604, 10, '241604INSLogFail', 'us_english', 598 
execute rdt.rdtAddMsg 241605, 10, '241605LenNotMatch', 'us_english', 598 

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN  241601 and 241650
