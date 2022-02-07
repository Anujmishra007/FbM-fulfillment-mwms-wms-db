--rdtHnMSwapLot04
exec rdt.rdtDropMsg 117901 , 117950

execute rdt.rdtAddMsg 117901, 10, '17901^Invalid Orders',   'us_english', 840
execute rdt.rdtAddMsg 117902, 10, '17902^Invalid SKU',      'us_english', 840
execute rdt.rdtAddMsg 117903, 10, '17903^Invalid LOT02',    'us_english', 840
execute rdt.rdtAddMsg 117904, 10, '17904^SKU Not In Ord',   'us_english', 840
execute rdt.rdtAddMsg 117905, 10, '17905^Invalid Label',    'us_english', 840
execute rdt.rdtAddMsg 117906, 10, '17906^Customer Ord',     'us_english', 840
execute rdt.rdtAddMsg 117907, 10, '17907^SKU OverPacked',   'us_english', 840
execute rdt.rdtAddMsg 117908, 10, '17908^UpdPKDET Fail',    'us_english', 840
execute rdt.rdtAddMsg 117909, 10, '17909^No LOT 2 Swap',    'us_english', 840
execute rdt.rdtAddMsg 117910, 10, '17910^UpdPKDET Fail',    'us_english', 840
execute rdt.rdtAddMsg 117911, 10, '17911^No LOT 2 Swap',    'us_english', 840
execute rdt.rdtAddMsg 117912, 10, '17912^No LOT 2 Swap',    'us_english', 840
execute rdt.rdtAddMsg 117913, 10, '17913^No LOT 2 Swap',    'us_english', 840
execute rdt.rdtAddMsg 117914, 10, '17914^Swap Lot Fail',    'us_english', 840
execute rdt.rdtAddMsg 117915, 10, '17915^Swap Lot Fail',    'us_english', 840
execute rdt.rdtAddMsg 117916, 10, '17916^Swap Lot Fail',    'us_english', 840
execute rdt.rdtAddMsg 117917, 10, '17917^No INV 2 Swap',    'us_english', 840
execute rdt.rdtAddMsg 117918, 10, '17918^UpdLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 117919, 10, '17919^InsLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 117920, 10, '17920^InsPKHDR Fail',    'us_english', 840
execute rdt.rdtAddMsg 117921, 10, '17921^UpdPKDET Fail',    'us_english', 840
execute rdt.rdtAddMsg 117922, 10, '17922^Get Label Fail',   'us_english', 840
execute rdt.rdtAddMsg 117923, 10, '17923^InsPKDET Failed',  'us_english', 840
execute rdt.rdtAddMsg 117924, 10, '17924^InsPKDET Failed',  'us_english', 840
execute rdt.rdtAddMsg 117925, 10, '17925^Assign Lbl Err',   'us_english', 840
execute rdt.rdtAddMsg 117926, 10, '17926^No Tracking #',    'us_english', 840
execute rdt.rdtAddMsg 117927, 10, '17927^Assign Lbl Err',   'us_english', 840
execute rdt.rdtAddMsg 117928, 10, '17928^Upd CaseID Err',   'us_english', 840
execute rdt.rdtAddMsg 117929, 10, '17929^nspGetRightErr',   'us_english', 840
execute rdt.rdtAddMsg 117930, 10, '17930^GenTLog3 Fail',    'us_english', 840


select * from rdt.rdtmsg (nolock) where message_id between 117901 and 117950



