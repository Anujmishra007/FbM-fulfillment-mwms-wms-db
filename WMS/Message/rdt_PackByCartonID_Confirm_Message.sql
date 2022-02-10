--rdt_PackByCartonID_Confirm
rdt.rdtDropMsg 137151 , 137200

execute rdt.rdtAddMsg 137151, 10, '37151^Fully Picked',     'us_english', 833
execute rdt.rdtAddMsg 137152, 10, '37152^Casecnt = 0',      'us_english', 833
execute rdt.rdtAddMsg 137153, 10, '37153^OffSetPDtlFail',   'us_english', 833
execute rdt.rdtAddMsg 137154, 10, '37154^OffSetPDtlFail',   'us_english', 833
execute rdt.rdtAddMsg 137155, 10, '37155^GetDetKeyFail',    'us_english', 833
execute rdt.rdtAddMsg 137156, 10, '37156^Ins PDtl Fail',    'us_english', 833
execute rdt.rdtAddMsg 137157, 10, '37157^INS RefKeyFail',   'us_english', 833
execute rdt.rdtAddMsg 137158, 10, '37158^OffSetPDtlFail',   'us_english', 833
execute rdt.rdtAddMsg 137159, 10, '37159^InsPHdrFail',      'us_english', 833
execute rdt.rdtAddMsg 137160, 10, '37160^GenLabelFail',     'us_english', 833
execute rdt.rdtAddMsg 137161, 10, '37161^InsPackDtlFail',   'us_english', 833
execute rdt.rdtAddMsg 137162, 10, '37162^InsPackDtlFail',   'us_english', 833
execute rdt.rdtAddMsg 137163, 10, '37163^UpdPackDtlFail',   'us_english', 833
execute rdt.rdtAddMsg 137164, 10, '37164^INS RDSNo Fail',   'us_english', 833
execute rdt.rdtAddMsg 137165, 10, '37165^SNO ady scan',     'us_english', 833
execute rdt.rdtAddMsg 137166, 10, '37166^INS PDInfoFail',   'us_english', 833
execute rdt.rdtAddMsg 137167, 10, '37167^UPD PDInfoFail',   'us_english', 833
execute rdt.rdtAddMsg 137168, 10, '37168^OffSetPDtlFail',   'us_english', 833
execute rdt.rdtAddMsg 137169, 10, '37169^PackCfm Fail',     'us_english', 833
execute rdt.rdtAddMsg 137170, 10, 'Packing List Printed',   'us_english', 833

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 137151 AND 137200