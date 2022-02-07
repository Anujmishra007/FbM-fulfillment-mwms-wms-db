--rdtfnc_MoveToUCC
--execute rdt.rdtdropmsg 82901, 82950

execute rdt.rdtAddMsg 82901, 10, '82901^TOLOC NEEDED',   'us_english'
execute rdt.rdtAddMsg 82902, 10, '82902^INV TOLOC',      'us_english'
execute rdt.rdtAddMsg 82903, 10, '82903^DIFF FACILITY',  'us_english'
execute rdt.rdtAddMsg 82904, 10, '82904^LOSEUCC TOLOC',  'us_english'
execute rdt.rdtAddMsg 82905, 10, '82905^FROMLOC NEEDED', 'us_english'
execute rdt.rdtAddMsg 82906, 10, '82906^INV FROMLOC',    'us_english'
execute rdt.rdtAddMsg 82907, 10, '82907^DIFF FACILITY',  'us_english'
execute rdt.rdtAddMsg 82908, 10, '82908^NOT LOSEUCC',    'us_english'
execute rdt.rdtAddMsg 82909, 10, '82909^Same FromToLOC', 'us_english'
execute rdt.rdtAddMsg 82910, 10, '82910^INV ID',         'us_english'
execute rdt.rdtAddMsg 82911, 10, '82911^SKU NEEDED',     'us_english'
execute rdt.rdtAddMsg 82912, 10, '82912^INV SKU',        'us_english'
execute rdt.rdtAddMsg 82913, 10, '82913^NO QTY TO MOVE', 'us_english'
execute rdt.rdtAddMsg 82915, 10, '82915^INV QTY',        'us_english'
execute rdt.rdtAddMsg 82916, 10, '82916^INV QTY',        'us_english'
execute rdt.rdtAddMsg 82917, 10, '82917^SKU NOT NEEDED', 'us_english'
execute rdt.rdtAddMsg 82918, 10, '82918^SKU NOT SAME',   'us_english'
execute rdt.rdtAddMsg 82919, 10, '82919^QTY NEEDED',     'us_english'
execute rdt.rdtAddMsg 82920, 10, '82920^QTYAVL NOTENUF', 'us_english'
execute rdt.rdtAddMsg 82921, 10, '82921^TOUCC NEEDED',   'us_english'
execute rdt.rdtAddMsg 82922, 10, '82922^TOUCC EXISTS',   'us_english'
execute rdt.rdtAddMsg 82923, 10, '82923^EXT UPD FAIL',   'us_english'
execute rdt.rdtAddMsg 82924, 10, '82924^WITHDRAW FAIL',  'us_english'
execute rdt.rdtAddMsg 82925, 10, '82925^DEPOSIT FAIL',   'us_english'
execute rdt.rdtAddMsg 82926, 10, '82926^WITHDRAW FAIL',  'us_english'
execute rdt.rdtAddMsg 82927, 10, '82927^DEPOSIT FAIL',   'us_english'
execute rdt.rdtAddMsg 82928, 10, '82928^RDTMOVE FAIL',   'us_english'
execute rdt.rdtAddMsg 82929, 10, '82929^INS UCC FAIL',   'us_english'
execute rdt.rdtAddMsg 82930, 10, '82930^CantMixSKU&UCC', 'us_english'
execute rdt.rdtAddMsg 82931, 10, '82931^OPTION NEEDED',  'us_english'
execute rdt.rdtAddMsg 82932, 10, '82932^INV OPTION',     'us_english'
execute rdt.rdtAddMsg 82933, 10, '82933^EXT UPD FAIL',   'us_english'

execute rdt.rdtAddMsg 82934, 10, '82934^GET KEY FAIL',   'us_english'
execute rdt.rdtAddMsg 82935, 10, '82935^InsTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 82936, 10, '82936^NO QTY TO MOVE', 'us_english'
execute rdt.rdtAddMsg 82937, 10, '82937^NoCandidateToMove', 'us_english'

-- (ChewKP02)
execute rdt.rdtAddMsg 82938, 10, '82938^UpdUCCFail', 'us_english'


-- (ChewKP03)
execute rdt.rdtAddMsg 82939, 10, '82939^InvalidFormat', 'us_english'

-- (yeekung01)
execute rdt.rdtAddMsg 82940, 10, '82940^MultiSKUBarCod', 'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 82901 AND 82950