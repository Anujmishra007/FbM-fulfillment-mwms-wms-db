
-- rdtHnMSwapLot03 
execute rdt.rdtDropMsg 100901 , 100950

execute rdt.rdtAddMsg 100901, 10, '00901^INVALID ORDER',     'us_english', 840
execute rdt.rdtAddMsg 100902, 10, '00902^INVALID SKU',       'us_english', 840
execute rdt.rdtAddMsg 100903, 10, '00903^INVALID LOT02',     'us_english', 840
execute rdt.rdtAddMsg 100904, 10, '00904^SKU NOT IN ORD',    'us_english', 840
execute rdt.rdtAddMsg 100905, 10, '00905^INVALID LABEL',     'us_english', 840
execute rdt.rdtAddMsg 100906, 10, '00906^COD >1 CARTON',     'us_english', 840
execute rdt.rdtAddMsg 100907, 10, '00907^LTR >1 CARTON',     'us_english', 840
execute rdt.rdtAddMsg 100908, 10, '00908^SKU OVERPACKED',    'us_english', 840
execute rdt.rdtAddMsg 100909, 10, '00909^UPDPKDET FAIL',     'us_english', 840
execute rdt.rdtAddMsg 100910, 10, '00910^NO LOT 2 SWAP',     'us_english', 840
execute rdt.rdtAddMsg 100911, 10, '00911^UPDPKDET Fail',     'us_english', 840
execute rdt.rdtAddMsg 100912, 10, '00912^NO LOT 2 SWAP',     'us_english', 840
execute rdt.rdtAddMsg 100913, 10, '00913^NO LOT 2 SWAP',     'us_english', 840
execute rdt.rdtAddMsg 100914, 10, '00914^NO LOT 2 SWAP',     'us_english', 840
execute rdt.rdtAddMsg 100915, 10, '00915^SWAP LOT FAIL',     'us_english', 840
execute rdt.rdtAddMsg 100916, 10, '00916^SWAP LOT FAIL',     'us_english', 840
execute rdt.rdtAddMsg 100917, 10, '00917^SWAP LOT FAIL',     'us_english', 840
execute rdt.rdtAddMsg 100918, 10, '00918^NO INV 2 SWAP',     'us_english', 840
execute rdt.rdtAddMsg 100919, 10, '00919^UPDLOG FAILED',     'us_english', 840
execute rdt.rdtAddMsg 100920, 10, '00920^INSLOG FAILED',     'us_english', 840
execute rdt.rdtAddMsg 100921, 10, '00921^INSPKHDR FAIL',     'us_english', 840
execute rdt.rdtAddMsg 100922, 10, '00922^NO TRACKING #',     'us_english', 840
execute rdt.rdtAddMsg 100923, 10, '00923^NO TRACKING #',     'us_english', 840
execute rdt.rdtAddMsg 100924, 10, '00924^ASSIGN TRK# ER',    'us_english', 840
execute rdt.rdtAddMsg 100925, 10, '00925^ASSIGN TRK# ER',    'us_english', 840
execute rdt.rdtAddMsg 100926, 10, '00926^UPDPKDET FAIL',     'us_english', 840
execute rdt.rdtAddMsg 100927, 10, '00927^GET LABEL FAIL',    'us_english', 840
execute rdt.rdtAddMsg 100928, 10, '00928^INSPKDET FAILED',   'us_english', 840
execute rdt.rdtAddMsg 100929, 10, '00929^INSPKDET Failed',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 100901 AND 100950
