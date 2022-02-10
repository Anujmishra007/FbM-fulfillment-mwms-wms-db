--rdt_840ExtInsPack10
execute rdt.rdtdropmsg 150901 , 150950

execute rdt.rdtAddMsg 150901, 10, '50901^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 150902, 10, '50902^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 150903, 10, '50903^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150904, 10, '50904^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150905, 10, '50905^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 150906, 10, '50906^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 150907, 10, '50907^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 150908, 10, '50908^GETKEY FAILED',   'us_english', 840
execute rdt.rdtAddMsg 150909, 10, '50909^GETKEY FAILED',   'us_english', 840
execute rdt.rdtAddMsg 150910, 10, '50910^RESET FAILED',    'us_english', 840
execute rdt.rdtAddMsg 150911, 10, '50911^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 150912, 10, '50912^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150913, 10, '50913^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150914, 10, '50914^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150915, 10, '50915^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150916, 10, '50916^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 150917, 10, '50917^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150918, 10, '50918^UPD CASE FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 150901 AND 150950
