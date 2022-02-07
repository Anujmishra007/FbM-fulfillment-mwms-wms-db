--rdt_833ExtVal01
execute rdt.rdtdropmsg 137201, 137250	

execute rdt.rdtAddMsg 137201, 10, '37201^Fully Picked',     'us_english', 833
execute rdt.rdtAddMsg 137202, 10, '37202^SKU NotExists',    'us_english', 833
execute rdt.rdtAddMsg 137203, 10, '37203^Duplicate CaseID', 'us_english', 833
execute rdt.rdtAddMsg 137204, 10, '37204^Duplicate Serial', 'us_english', 833
execute rdt.rdtAddMsg 137205, 10, '37205^SrCntNotMatch',    'us_english', 833
execute rdt.rdtAddMsg 137206, 10, '37206^SrLenNotMatch',    'us_english', 833
execute rdt.rdtAddMsg 137207, 10, '37207^Over Scanned',     'us_english', 833
execute rdt.rdtAddMsg 137208, 10, '37208^Casecnt = 0',      'us_english', 833
execute rdt.rdtAddMsg 137209, 10, '37209^Over Scanned',     'us_english', 833
execute rdt.rdtAddMsg 137210, 10, '37210^Invalid Data',     'us_english', 833
execute rdt.rdtAddMsg 137211, 10, '37211^Over Scanned',     'us_english', 833

select * from rdt.rdtmsg (nolock) where message_id between 137201 AND 137250	
