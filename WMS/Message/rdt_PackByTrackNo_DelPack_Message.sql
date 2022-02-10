--rdt_PackByTrackNo_DelPack
--execute rdt.rdtdropmsg 55451 , 55500

execute rdt.rdtAddMsg 55451, 10, '55451^NO PICKSLIPNO',      'us_english'
execute rdt.rdtAddMsg 55452, 10, '55452^DEL PKDTL FAIL',     'us_english'
execute rdt.rdtAddMsg 55453, 10, '55453^DEL PKHDR FAIL',     'us_english'
execute rdt.rdtAddMsg 55454, 10, '55454^DEL PKINF FAIL',     'us_english'
execute rdt.rdtAddMsg 55455, 10, '55455^UPD QTYMV FAIL',     'us_english'
execute rdt.rdtAddMsg 55456, 10, '55456^DEL TKLOG FAIL',     'us_english'
