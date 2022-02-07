
-- rdtfnc_PrintShopLabel 
-- execute rdt.rdtDropMsg 80701, 80750

execute rdt.rdtAddMsg 80701, 10, '80701^LOADKEY IS REQ',     'us_english'
execute rdt.rdtAddMsg 80702, 10, '80702^BAD LOADKEY',        'us_english'
execute rdt.rdtAddMsg 80703, 10, '80703^NOLABELPRINTER',     'us_english'
execute rdt.rdtAddMsg 80704, 10, '80704^DWNOTSETUP',         'us_english'
execute rdt.rdtAddMsg 80705, 10, '80705^TGETDB NOT SET',     'us_english'
execute rdt.rdtAddMsg 80706, 10, '80706^DWNOTSETUP',         'us_english'
execute rdt.rdtAddMsg 80707, 10, '80707^TGETDB NOT SET',     'us_english'
execute rdt.rdtAddMsg 80708, 10, '80708^INSERTPRTFAIL',      'us_english'
execute rdt.rdtAddMsg 80709, 10, '80709^INSERTPRTFAIL',      'us_english'
execute rdt.rdtAddMsg 80710, 10, '80710^UPD BOX # FAIL',     'us_english'
execute rdt.rdtAddMsg 80711, 10, '80711^INS CKLP FAIL',      'us_english'

--SOS294060
execute rdt.rdtAddMsg 80712, 10, '80712^LABEL TYPE req',     'us_english'
execute rdt.rdtAddMsg 80713, 10, '80713^INV LABEL TYPE',     'us_english'
execute rdt.rdtAddMsg 80714, 10, '80714^SHOP LABEL REQ',     'us_english'


-- (ChewKP01)
execute rdt.rdtAddMsg 80715, 10, '80715^DiffFacility',       'us_english'
execute rdt.rdtAddMsg 80716, 10, '80716^DiffStorer',         'us_english'
execute rdt.rdtAddMsg 80717, 10, '80717^WRONG LBL TYPE',     'us_english'