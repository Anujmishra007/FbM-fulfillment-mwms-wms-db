--rdt_593PrintUA01
--execute rdt.rdtDropMsg 123151 , 123200

execute rdt.rdtAddMsg 123151, 10, '23151^LabelPrnterReq',    'us_english'
execute rdt.rdtAddMsg 123152, 10, '23152^PaperPrnterReq',    'us_english'
execute rdt.rdtAddMsg 123153, 10, '23153^UCCorDropIDReq',    'us_english'
execute rdt.rdtAddMsg 123154, 10, '23154^InvalidValue',    'us_english'
execute rdt.rdtAddMsg 123155, 10, '23155^InsPackHdFail',    'us_english'
execute rdt.rdtAddMsg 123156, 10, '23156^InsPickHdrFail',    'us_english'
execute rdt.rdtAddMsg 123157, 10, '23157^InsPickInfoFail',    'us_english'

execute rdt.rdtAddMsg 123158, 10, '23158^GenLblSPNotFound',    'us_english'
execute rdt.rdtAddMsg 115259, 10, '15259^UpdPickDetFail',    'us_english'

execute rdt.rdtAddMsg 123160, 10, '23160^NoRecFound',    'us_english'
execute rdt.rdtAddMsg 123161, 10, '23161^TemplateNotFound',    'us_english'
execute rdt.rdtAddMsg 123162, 10, '23162^TemplateNotFound',    'us_english'
execute rdt.rdtAddMsg 123163, 10, '23163^InsPickHdrFail',    'us_english'
execute rdt.rdtAddMsg 123164, 10, '23164^UpdPackHdrFail',    'us_english'
execute rdt.rdtAddMsg 123165, 10, '23165^UpdPickDetFail',    'us_english'
execute rdt.rdtAddMsg 123166, 10, '23166^nspg_GetKey',    'us_english'
execute rdt.rdtAddMsg 123167, 10, '23167^GetTrack# Fail',    'us_english'
execute rdt.rdtAddMsg 123168, 10, '23168^UpdOrdersFail',    'us_english'
execute rdt.rdtAddMsg 123169, 10, '23169^nspg_GetKey',    'us_english'

-- WMS-10521
execute rdt.rdtAddMsg 123170, 10, '23170^INS PACKInf Fail',    'us_english'

