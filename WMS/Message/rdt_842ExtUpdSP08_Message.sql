--rdt_842ExtUpdSP08
execute rdt.rdtDropMsg 151151, 151200

execute rdt.rdtAddMsg 151151, 10, '151151^InvDropID',        'us_english', 842
execute rdt.rdtAddMsg 151152, 10, '151152^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151153, 10, '151153^PickNotComplete',  'us_english', 842
execute rdt.rdtAddMsg 151154, 10, '151154^NoRecToProcess',   'us_english', 842
execute rdt.rdtAddMsg 151155, 10, '151155^SKuNotIntote',     'us_english', 842
execute rdt.rdtAddMsg 151156, 10, '151156^QtyExceeded',      'us_english', 842
execute rdt.rdtAddMsg 151157, 10, '151157^InsPickHdrFail',   'us_english', 842
execute rdt.rdtAddMsg 151158, 10, '151158^UpdPickDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151159, 10, '151159^InsPickInfoFail',  'us_english', 842
execute rdt.rdtAddMsg 151160, 10, '151160^CreatePHdrFail',   'us_english', 842
execute rdt.rdtAddMsg 151161, 10, '151161^NoLabelNoGen',     'us_english', 842
execute rdt.rdtAddMsg 151162, 10, '151162^NoLabelNoGen',     'us_english', 842
execute rdt.rdtAddMsg 151163, 10, '151163^InsPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151164, 10, '151163^InsCtnTrackErr',   'us_english', 842
execute rdt.rdtAddMsg 151165, 10, '151165^TrackNoInUsed',    'us_english', 842
execute rdt.rdtAddMsg 151166, 10, '151166^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151167, 10, '151167^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151168, 10, '151168^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151169, 10, '151169^UpdPickDetFull',   'us_english', 842
execute rdt.rdtAddMsg 151170, 10, '151170^UpdPickDetFull',   'us_english', 842
execute rdt.rdtAddMsg 151171, 10, '151171^nspg_GetKey',      'us_english', 842
execute rdt.rdtAddMsg 151172, 10, '151172^INS PKDtl Fail',   'us_english', 842
execute rdt.rdtAddMsg 151173, 10, '151173^UpdPickDetFaill',  'us_english', 842
execute rdt.rdtAddMsg 151174, 10, '151174^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151175, 10, '151175^UpdDropIDFail',    'us_english', 842
execute rdt.rdtAddMsg 151176, 10, '151176^InsPackInfoFail',  'us_english', 842
execute rdt.rdtAddMsg 151177, 10, '151177^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151178, 10, '151178^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151179, 10, '151179^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151180, 10, '151180^InvalidOption',    'us_english', 842
execute rdt.rdtAddMsg 151181, 10, '151181^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151182, 10, '151182^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151183, 10, '151183^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151184, 10, '151184^PickNotDone',      'us_english', 842
execute rdt.rdtAddMsg 151185, 10, '151185^PickNotComplete',  'us_english', 842
execute rdt.rdtAddMsg 151186, 10, '151186^NoRecToProcess',   'us_english', 842
execute rdt.rdtAddMsg 151187, 10, '151187^LabelPrinterReq',  'us_english', 842
execute rdt.rdtAddMsg 151188, 10, '151188^PaperPrinterReq',  'us_english', 842
execute rdt.rdtAddMsg 151189, 10, '151189^PackCfm Fail',     'us_english', 842
execute rdt.rdtAddMsg 151190, 10, '151190^PackCfm Fail',     'us_english', 842

--FCR-1445
execute rdt.rdtAddMsg 151191, 10, '151191^PrntLblFail',      'us_english', 842, 0, '151191 Label printing'
execute rdt.rdtAddMsg 151192, 10, '151192^PrntLblFail',      'us_english', 842, 0, 'failed,please use'
execute rdt.rdtAddMsg 151193, 10, '151193^PrntLblFail',      'us_english', 842, 0, 'Fn593'
execute rdt.rdtAddMsg 151194, 10, '151194^MissSP',           'us_english', 842, 0, '151194 rdt_593PrintHK01 does not exist'

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151151 AND 151200