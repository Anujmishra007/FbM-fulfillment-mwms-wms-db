-- rdtfnc_TM_ClusterPick
rdt.rdtDropMsg 148901 , 148950	

execute rdt.rdtAddMsg 148901, 10, '48901^CartId req',       'us_english', 640
execute rdt.rdtAddMsg 148902, 10, '48902^CartIdNotMatch',   'us_english', 640
execute rdt.rdtAddMsg 148903, 10, '48903^Need Loc',         'us_english', 640
execute rdt.rdtAddMsg 148904, 10, '48904^Loc Not Match',    'us_english', 640
execute rdt.rdtAddMsg 148905, 10, '48905^Need Case Id',     'us_english', 640
execute rdt.rdtAddMsg 148906, 10, '48906^CaseIdNotMatch',   'us_english', 640
execute rdt.rdtAddMsg 148907, 10, '48907^Need SKU',         'us_english', 640
execute rdt.rdtAddMsg 148908, 10, '48908^Invalid SKU',      'us_english', 640
execute rdt.rdtAddMsg 148909, 10, '48909^MultiSKUBarcod',   'us_english', 640
execute rdt.rdtAddMsg 148910, 10, '48910^SKU Not Match',    'us_english', 640
execute rdt.rdtAddMsg 148911, 10, '48911^Invalid QTY',      'us_english', 640
execute rdt.rdtAddMsg 148912, 10, '48912^AllShortWithQTY',  'us_english', 640
execute rdt.rdtAddMsg 148913, 10, '48913^Over Pick',        'us_english', 640
execute rdt.rdtAddMsg 148914, 10, '48914^Option required',  'us_english', 640
execute rdt.rdtAddMsg 148915, 10, '48915^Invalid Option',   'us_english', 640
execute rdt.rdtAddMsg 148916, 10, '48916^Option required',  'us_english', 640
execute rdt.rdtAddMsg 148917, 10, '48917^Invalid Option',   'us_english', 640
execute rdt.rdtAddMsg 148918, 10, '48918^ToLOC needed',     'us_english', 640
execute rdt.rdtAddMsg 148919, 10, '48919^ToLOC Diff',       'us_english', 640
execute rdt.rdtAddMsg 148920, 10, '48920^Invalid LOC',      'us_english', 640
execute rdt.rdtAddMsg 148921, 10, '48921^Reason needed',    'us_english', 640
execute rdt.rdtAddMsg 148922, 10, '48922^NextTaskScnErr',   'us_english', 640
execute rdt.rdtAddMsg 148923, 10, '48923^Invalid Reason',   'us_english', 640
execute rdt.rdtAddMsg 148924, 10, '48924^InsSkipTskFail',   'us_english', 640
execute rdt.rdtAddMsg 148925, 10, '48925^UpdTaskdetFail',   'us_english', 640
execute rdt.rdtAddMsg 148926, 10, '48926^UpdTaskdetFail',   'us_english', 640

-- WMS-17689
execute rdt.rdtAddMsg 148927, 10, '48924^InsSkipTskFail',   'us_english', 640
execute rdt.rdtAddMsg 148928, 10, '48925^UpdTaskdetFail',   'us_english', 640
execute rdt.rdtAddMsg 148929, 10, '48926^UpdTaskdetFail',   'us_english', 640



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148901 AND 148950	