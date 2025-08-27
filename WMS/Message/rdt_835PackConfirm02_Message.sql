--rdt_835PackConfirm02
rdt.rdtDropMsg 237901 , 237950

execute rdt.rdtAddMsg 237901, 10, '237901 Fully Packed ',   'us_english', 835
execute rdt.rdtAddMsg 237902, 10, '237902OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 237903, 10, '237903OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 237904, 10, '237904 GetDetKeyFail',   'us_english', 835
execute rdt.rdtAddMsg 237905, 10, '237905 Ins PDtl Fail',   'us_english', 835
execute rdt.rdtAddMsg 237906, 10, '237906OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 237907, 10, '237907OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 237908, 10, '237908OffSetPDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 237909, 10, '237909 Ins PackH Err',   'us_english', 835
execute rdt.rdtAddMsg 237910, 10, '237910InsPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 237911, 10, '237911Ins PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 237912, 10, '237912Upd PInfo Fail',   'us_english', 835
execute rdt.rdtAddMsg 237913, 10, '237913UpdPackDtlFail',   'us_english', 835
execute rdt.rdtAddMsg 237914, 10, '237914InsPackSNo Err',   'us_english', 835
execute rdt.rdtAddMsg 237915, 10, '237915 SNO ady scan ',   'us_english', 835
execute rdt.rdtAddMsg 237916, 10, '237916 UPD SNO Err  ',   'us_english', 835
execute rdt.rdtAddMsg 237917, 10, '237917InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 237918, 10, '237918InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 237919, 10, '237919InsPldInfoFail',   'us_english', 835
execute rdt.rdtAddMsg 237920, 10, '237920 PackCfm Fail ',   'us_english', 835
execute rdt.rdtAddMsg 237921, 10, '237921 Scan Out Fail',   'us_english', 835
execute rdt.rdtAddMsg 237922, 10, '237922 UPD UCC Err  ',   'us_english', 835

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 237901 AND 237950