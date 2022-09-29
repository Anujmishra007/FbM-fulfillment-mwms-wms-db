
-- rdt_840ExtUpd02 
execute rdt.rdtDropMsg 94801 , 94850
execute rdt.rdtAddMsg 94801, 10, '94801^NO PKSLIP',         'us_english', 840
execute rdt.rdtAddMsg 94802, 10, '94802^NO ORDERKEY',       'us_english', 840
execute rdt.rdtAddMsg 94803, 10, '94803^Upd OdHdr Fail',    'us_english', 840
execute rdt.rdtAddMsg 94804, 10, '94804^Upd OdDtl Fail',    'us_english', 840
execute rdt.rdtAddMsg 94805, 10, '94805^Upd LpDtl Fail',    'us_english', 840
execute rdt.rdtAddMsg 94806, 10, '94806^nspGetRightErr',    'us_english', 840
execute rdt.rdtAddMsg 94807, 10, '94807^GenTLog3 Fail',     'us_english', 840
execute rdt.rdtAddMsg 94808, 10, '94808^NO TRACK NO',       'us_english', 840
execute rdt.rdtAddMsg 94809, 10, '94809^INV TRACK NO',      'us_english', 840
execute rdt.rdtAddMsg 94810, 10, '94810^UPD TRACK FAIL',    'us_english', 840
execute rdt.rdtAddMsg 94811, 10, '94811^Assign Lbl Err',    'us_english', 840
execute rdt.rdtAddMsg 94812, 10, '94812^UPD PGET FAIL',     'us_english', 840
execute rdt.rdtAddMsg 94813, 10, '94813^NoPaperPrinter',    'us_english', 840
execute rdt.rdtAddMsg 94814, 10, '94814^DWNOTSetup',        'us_english', 840
execute rdt.rdtAddMsg 94815, 10, '94815^TgetDB Not Set',    'us_english', 840
execute rdt.rdtAddMsg 94816, 10, '94816^NoLblPrinter',      'us_english', 840
execute rdt.rdtAddMsg 94817, 10, '94817^DWNOTSetup',        'us_english', 840
execute rdt.rdtAddMsg 94818, 10, '94818^TgetDB Not Set',    'us_english', 840
execute rdt.rdtAddMsg 94819, 10, '94819^NoLblPrinter',      'us_english', 840
execute rdt.rdtAddMsg 94820, 10, '94820^DWNOTSetup',        'us_english', 840
execute rdt.rdtAddMsg 94821, 10, '94821^TgetDB Not Set',    'us_english', 840
execute rdt.rdtAddMsg 94822, 10, '94822^NO TRACKING #',     'us_english', 840
execute rdt.rdtAddMsg 94823, 10, '94823^GET TRACK# Err',    'us_english', 840
execute rdt.rdtAddMsg 94824, 10, '94824^REL TRACK# Err',    'us_english', 840
execute rdt.rdtAddMsg 94825, 10, '94825^UPD Orders Err',    'us_english', 840
execute rdt.rdtAddMsg 94826, 10, '94826^UPD PICKDTL Er',    'us_english', 840
execute rdt.rdtAddMsg 94827, 10, '94827^UPD PACKDTL Er',    'us_english', 840

--WMS-20115
execute rdt.rdtAddMsg 94828, 10, '94828^UPD PACKINF Er',    'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 94801 AND 94850

