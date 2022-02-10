--ispCCDetailUpd_HK02
execute rdt.rdtdropmsg 132551 , 132600

execute rdt.rdtAddMsg 132551, 10, '32551^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132552, 10, '32552^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132553, 10, '32553^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132554, 10, '32554^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132555, 10, '32555^GetKeyFail',       'us_english', 732
execute rdt.rdtAddMsg 132556, 10, '32556^GetSheetNoFail',   'us_english', 732
execute rdt.rdtAddMsg 132557, 10, '32557^InsertCCFail',     'us_english', 732
execute rdt.rdtAddMsg 132558, 10, '32558^InsertCCFail',     'us_english', 732
execute rdt.rdtAddMsg 132559, 10, '32559^InsertCCFail',     'us_english', 732
execute rdt.rdtAddMsg 132560, 10, '32560^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132561, 10, '32561^UpdCounterFail',   'us_english', 732
execute rdt.rdtAddMsg 132562, 10, '32562^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132563, 10, '32563^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132564, 10, '32564^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132565, 10, '32565^UpdCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132566, 10, '32566^DelCCDtlFail',     'us_english', 732
execute rdt.rdtAddMsg 132567, 10, '32567^ResetCCDtlFail',   'us_english', 732
execute rdt.rdtAddMsg 132568, 10, '32568^SKU not in LOC',   'us_english', 732
execute rdt.rdtAddMsg 132568, 10, '32568^QtyOverLocMax',    'us_english', 732

select * from rdt.rdtmsg (nolock) where message_id between 132551 AND 132600
