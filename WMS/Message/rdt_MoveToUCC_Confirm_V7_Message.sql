--rdtfnc_MoveToUCC_V7
execute rdt.rdtdropmsg 148401 , 148450	

execute rdt.rdtAddMsg 148401, 10, '48401^WITHDRAW FAIL',    'us_english', 639
execute rdt.rdtAddMsg 148402, 10, '48402^DEPOSIT FAIL',     'us_english', 639
execute rdt.rdtAddMsg 148403, 10, '48403^INS UCC FAIL',     'us_english', 639
execute rdt.rdtAddMsg 148404, 10, '48404^UpdUCCFail',       'us_english', 639
execute rdt.rdtAddMsg 148405, 10, '48405^CantMixSKU&UCC',   'us_english', 639

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148401 AND 148450