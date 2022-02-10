--rdt_CheckEmptyPallet
execute rdt.rdtdropmsg 53451 , 53500

execute rdt.rdtAddMsg 53451, 10, '53451^Pallet On Hold',        'us_english'
execute rdt.rdtAddMsg 53452, 10, '53452^PalletMixStore',         'us_english'
execute rdt.rdtAddMsg 53453, 10, '53453^MixBond/Unbond',        'us_english'
execute rdt.rdtAddMsg 53454, 10, '53454^Mix AC/Ambient',        'us_english'
execute rdt.rdtAddMsg 53455, 10, '53455^PalletNotEmpty',        'us_english'