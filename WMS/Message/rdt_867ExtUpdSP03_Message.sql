--rdt_867ExtUpdSP03
exec rdt.rdtDropMsg 153001 , 153050

execute rdt.rdtAddMsg 153001, 10, '53001^PickSlip req',     'us_english', 867
execute rdt.rdtAddMsg 153002, 10, '53002^Del PackDt Err',   'us_english', 867
execute rdt.rdtAddMsg 153003, 10, '53003^Over Pack',        'us_english', 867
execute rdt.rdtAddMsg 153004, 10, '53004^Fail scan-in ',    'us_english', 867
execute rdt.rdtAddMsg 153005, 10, '53005^InsPHdrFail',      'us_english', 867
execute rdt.rdtAddMsg 153006, 10, '53006^GenLabelNoFail',   'us_english', 867
execute rdt.rdtAddMsg 153007, 10, '53007^GenLabelNoFail',   'us_english', 867
execute rdt.rdtAddMsg 153008, 10, '53008^InsPackDtlFail',   'us_english', 867
execute rdt.rdtAddMsg 153009, 10, '53009^No Lbl Printer',   'us_english', 867
execute rdt.rdtAddMsg 153010, 10, '53010^No WinPrinter',    'us_english', 867
execute rdt.rdtAddMsg 153011, 10, '53011^Setup FilePath',   'us_english', 867
execute rdt.rdtAddMsg 153012, 10, '53012^InsPackDtlFail',   'us_english', 867
execute rdt.rdtAddMsg 153013, 10, '53013^UpdPackDtlFail',   'us_english', 867


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 153001 AND 153050

