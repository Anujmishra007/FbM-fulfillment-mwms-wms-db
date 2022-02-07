--rdt_832ExtPack01
rdt.rdtDropMsg 144901 , 144950

execute rdt.rdtAddMsg 144901, 10, '44901^Invalid PKSlip',   'us_english', 832
execute rdt.rdtAddMsg 144902, 10, '44902^Multi SKU Ctn',    'us_english', 832
execute rdt.rdtAddMsg 144903, 10, '44903^Setup CaseCnt',    'us_english', 832
execute rdt.rdtAddMsg 144904, 10, '44904^Over Pack',        'us_english', 832
execute rdt.rdtAddMsg 144905, 10, '44905^Fail Scan In',     'us_english', 832
execute rdt.rdtAddMsg 144906, 10, '44906^InsPHdrFail',      'us_english', 832
execute rdt.rdtAddMsg 144907, 10, '44907^GenLabelNoFail',   'us_english', 832
execute rdt.rdtAddMsg 144908, 10, '44908^GenLabelNoFail',   'us_english', 832
execute rdt.rdtAddMsg 144909, 10, '44909^InsPackDtlFail',   'us_english', 832
execute rdt.rdtAddMsg 144910, 10, '44910^INSPackInfFail',   'us_english', 832
execute rdt.rdtAddMsg 144911, 10, '44911^OffSetPDtlFail',   'us_english', 832
execute rdt.rdtAddMsg 144912, 10, '44912^OffSetPDtlFail',   'us_english', 832
execute rdt.rdtAddMsg 144913, 10, '44913^GetDetKeyFail',    'us_english', 832
execute rdt.rdtAddMsg 144914, 10, '44914^Ins PDtl Fail',    'us_english', 832
execute rdt.rdtAddMsg 144915, 10, '44915^INS RefKeyFail',   'us_english', 832
execute rdt.rdtAddMsg 144916, 10, '44916^OffSetPDtlFail',   'us_english', 832
execute rdt.rdtAddMsg 144917, 10, '44917^OffSetPDtlFail',   'us_english', 832

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 144901 AND 144950