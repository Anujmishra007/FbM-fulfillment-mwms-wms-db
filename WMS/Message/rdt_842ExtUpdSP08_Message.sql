--rdt_842ExtUpdSP08
execute rdt.rdtDropMsg 151151, 151200

execute rdt.rdtAddMsg 151151, 10, '51151^InvDropID',        'us_english', 842
execute rdt.rdtAddMsg 151152, 10, '51152^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151153, 10, '51153^PickNotComplete',  'us_english', 842
execute rdt.rdtAddMsg 151154, 10, '51154^NoRecToProcess',   'us_english', 842
execute rdt.rdtAddMsg 151155, 10, '51155^SKuNotIntote',     'us_english', 842
execute rdt.rdtAddMsg 151156, 10, '51156^QtyExceeded',      'us_english', 842
execute rdt.rdtAddMsg 151157, 10, '51157^InsPickHdrFail',   'us_english', 842
execute rdt.rdtAddMsg 151158, 10, '51158^UpdPickDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151159, 10, '51159^InsPickInfoFail',  'us_english', 842
execute rdt.rdtAddMsg 151160, 10, '51160^CreatePHdrFail',   'us_english', 842
execute rdt.rdtAddMsg 151161, 10, '51161^NoLabelNoGen',     'us_english', 842
execute rdt.rdtAddMsg 151162, 10, '51162^NoLabelNoGen',     'us_english', 842
execute rdt.rdtAddMsg 151163, 10, '51163^InsPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151164, 10, '51163^InsCtnTrackErr',   'us_english', 842
execute rdt.rdtAddMsg 151165, 10, '51165^TrackNoInUsed',    'us_english', 842
execute rdt.rdtAddMsg 151166, 10, '51166^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151167, 10, '51167^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151168, 10, '51168^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151169, 10, '51169^UpdPickDetFull',   'us_english', 842
execute rdt.rdtAddMsg 151170, 10, '51170^UpdPickDetFull',   'us_english', 842
execute rdt.rdtAddMsg 151171, 10, '51171^nspg_GetKey',      'us_english', 842
execute rdt.rdtAddMsg 151172, 10, '51172^INS PKDtl Fail',   'us_english', 842
execute rdt.rdtAddMsg 151173, 10, '51173^UpdPickDetFaill',  'us_english', 842
execute rdt.rdtAddMsg 151174, 10, '51174^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151175, 10, '51175^UpdDropIDFail',    'us_english', 842
execute rdt.rdtAddMsg 151176, 10, '51176^InsPackInfoFail',  'us_english', 842
execute rdt.rdtAddMsg 151177, 10, '51177^UpdPackDetFail',   'us_english', 842
execute rdt.rdtAddMsg 151178, 10, '51178^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151179, 10, '51179^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151180, 10, '51180^InvalidOption',    'us_english', 842
execute rdt.rdtAddMsg 151181, 10, '51181^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151182, 10, '51182^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151183, 10, '51183^UpdEcommFail',     'us_english', 842
execute rdt.rdtAddMsg 151184, 10, '51184^PickNotDone',      'us_english', 842
execute rdt.rdtAddMsg 151185, 10, '51185^PickNotComplete',  'us_english', 842
execute rdt.rdtAddMsg 151186, 10, '51186^NoRecToProcess',   'us_english', 842
execute rdt.rdtAddMsg 151187, 10, '51187^LabelPrinterReq',  'us_english', 842
execute rdt.rdtAddMsg 151188, 10, '51188^PaperPrinterReq',  'us_english', 842
execute rdt.rdtAddMsg 151189, 10, '51189^PackCfm Fail',     'us_english', 842
execute rdt.rdtAddMsg 151190, 10, '51190^PackCfm Fail',     'us_english', 842

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151151 AND 151200