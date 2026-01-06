--rdt_573ExtValidSP09
--UWP-38852
execute rdt.rdtdropmsg 218354, 218359
execute rdt.rdtdropmsg 218379, 218382

execute rdt.rdtAddMsg 218354, 10, '218354 Mix COD',  'us_english', 573
execute rdt.rdtAddMsg 218355, 10, '218355 Mix SKU',  'us_english', 573
execute rdt.rdtAddMsg 218356, 10, '218356 ID already in STORAGE',  'us_english', 573
execute rdt.rdtAddMsg 218357, 10, '218357 Not STAGING LOC',  'us_english', 573
execute rdt.rdtAddMsg 218358, 10, '218358 BONDED CANT MIX',  'us_english', 573
execute rdt.rdtAddMsg 218359, 10, '218359 NON-BONDED CANT MIX',  'us_english', 573

execute rdt.rdtAddMsg 218379, 10, '218379 Pallet with 1 COD - Xock Pallet',  'us_english', 573
execute rdt.rdtAddMsg 218380, 10, '218380 Pallet with 2  COD - FF Pallet',  'us_english', 573
execute rdt.rdtAddMsg 218381, 10, '218381 Missing COD on Lottable03',  'us_english', 573
execute rdt.rdtAddMsg 218382, 10, '218382 No SO in lottable10',  'us_english', 573


select * from rdt.rdtmsg (nolock) where message_id in ( 218354, 218355, 218356, 218357, 218358, 218359, 218379, 218380, 218381, 218382)
