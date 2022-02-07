--execute rdt.rdtdropmsg 77501, 77550
execute rdt.rdtAddMsg 77501, 10, '77501^SHOP NO req',        'us_english'
execute rdt.rdtAddMsg 77502, 10, '77502^BAD SHOPNO',         'us_english'
execute rdt.rdtAddMsg 77503, 10, '77503^SECTION req',        'us_english'
execute rdt.rdtAddMsg 77504, 10, '77504^BAD SECTION',        'us_english'
execute rdt.rdtAddMsg 77505, 10, '77505^SEPARATE req',       'us_english'
execute rdt.rdtAddMsg 77506, 10, '77506^BAD SEPARATE',       'us_english'
execute rdt.rdtAddMsg 77507, 10, '77507^PRINT QTY req',      'us_english'
execute rdt.rdtAddMsg 77508, 10, '77508^BAD PRINT QTY',      'us_english'
execute rdt.rdtAddMsg 77509, 10, '77509^NOLABELPRINTER',     'us_english'
execute rdt.rdtAddMsg 77510, 10, '77510^DWNOTSETUP',         'us_english'
execute rdt.rdtAddMsg 77511, 10, '77511^TGETDB NOT SET',     'us_english'
execute rdt.rdtAddMsg 77512, 10, '77512^INSERTPRTFAIL',      'us_english'
execute rdt.rdtAddMsg 77513, 10, '77513^BAD DIST CTR',       'us_english'
execute rdt.rdtAddMsg 77514, 10, '77514^UPD BOX # FAIL',     'us_english'
execute rdt.rdtAddMsg 77515, 10, '77515^STORERKEY req',      'us_english'
execute rdt.rdtAddMsg 77516, 10, '77516^BAD STORERKEY',      'us_english'

-- (james01)
execute rdt.rdtAddMsg 77517, 10, '77517^INS CKLP FAIL',      'us_english'

-- (james02)
execute rdt.rdtAddMsg 77518, 10, '77518^Shop <> Brand',      'us_english'

-- SOS293347 (james04)
execute rdt.rdtAddMsg 77519, 10, '77519^LABEL TYPE REQ',     'us_english'
execute rdt.rdtAddMsg 77520, 10, '77520^INV LABEL TYPE',     'us_english'
execute rdt.rdtAddMsg 77521, 10, '77521^INV LABEL TYPE',     'us_english'

select * from rdt.rdtmsg (nolock) where message_id between '77501' and '77550'



