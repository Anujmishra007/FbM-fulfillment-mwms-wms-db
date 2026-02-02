--rdtfnc_TM_PutawayFrom_JCB
--FCR-3954

rdt.rdtdropmsg 237101, 237150

execute rdt.rdtAddMsg 237101, 10, '237101^MHE Needed',            'us_english', 1871
execute rdt.rdtAddMsg 237102, 10, '237102^Invalid MHE',           'us_english', 1871
execute rdt.rdtAddMsg 237103, 10, '237103^InvalidNewMHE',         'us_english', 1871, 0, '237103 Invalid New MHE'
execute rdt.rdtAddMsg 237104, 10, '237104^AreaKeyNeeded',         'us_english', 1871, 0, '237104 Area Key is Needed'
execute rdt.rdtAddMsg 237105, 10, '237105^InvAreaKey',            'us_english', 1871, 0, '237105 Invalid Area Key'
execute rdt.rdtAddMsg 237106, 10, '237106^InvAreaKey',            'us_english', 1871, 0, '237106 Not User Area Key'
execute rdt.rdtAddMsg 237107, 10, '237107^NoPermission',          'us_english', 1871, 0, '237107 No Permission'
execute rdt.rdtAddMsg 237108, 10, '237108^NoTaskFound',           'us_english', 1871, 0, '237108 No Task Found'
execute rdt.rdtAddMsg 237109, 10, '237109^UpdTaskFail',           'us_english', 1871, 0, '237109 Update Task Failed'
execute rdt.rdtAddMsg 237110, 10, '237110^IDNeeded',              'us_english', 1871, 0, '237110 ID is Needed'
execute rdt.rdtAddMsg 237111, 10, '237111^IDNotMatch',            'us_english', 1871, 0, '237111 ID Does Not Exist'
execute rdt.rdtAddMsg 237112, 10, '237112^IDNotMatch',            'us_english', 1871, 0, '237112 ID Does Not Match'
execute rdt.rdtAddMsg 237113, 10, '237113^InvalidID',             'us_english', 1871, 0, '237113 Invalid ID'
execute rdt.rdtAddMsg 237114, 10, '237114^NoTaskFound',           'us_english', 1871, 0, '237114 No Task is Found'
execute rdt.rdtAddMsg 237115, 10, '237115^DiffAreaKey',           'us_english', 1871, 0, '237115 Different Area Key'
execute rdt.rdtAddMsg 237116, 10, '237116^OverWeight',            'us_english', 1871, 0, '237116 Scanned Pallet is Over Weight'
execute rdt.rdtAddMsg 237117, 10, '237117^PutawayZoneIsExcluded', 'us_english', 1871, 0, '237117 Putaway Zone is Excluded'
execute rdt.rdtAddMsg 237118, 10, '237118^ToLocNeed',             'us_english', 1871, 0, '237118 ToLoc is Needed'
execute rdt.rdtAddMsg 237119, 10, '237119^LocNotMatch',           'us_english', 1871, 0, '237119 Loc Does Not Match'
execute rdt.rdtAddMsg 237120, 10, '237120^InTransitLoc',          'us_english', 1871, 0, '237120 ToLoc is Transit Loc'
execute rdt.rdtAddMsg 237121, 10, '237121^OverWriteFail',         'us_english', 1871, 0, '237121 OverWrite Fail'
execute rdt.rdtAddMsg 237122, 10, '237122^ConfirmFail',           'us_english', 1871, 0, '237122 Confirm Putaway Failed'
execute rdt.rdtAddMsg 237123, 10, '237123^Reason needed',         'us_english', 1871, 0, '237123 Reason Code is Needed'
execute rdt.rdtAddMsg 237124, 10, '237124^InsSkipTskFail',        'us_english', 1871, 0, '237124 Insert Skip Task Fail'
execute rdt.rdtAddMsg 237125, 10, '237125^UpdSkipTskFail',        'us_english', 1871, 0, '237125 Update Skip Task Fail'
execute rdt.rdtAddMsg 237126, 10, '237126^UpdSkipTskFail',        'us_english', 1871, 0, '237126 Update Skip Task Fail'
execute rdt.rdtAddMsg 237127, 10, '237127^InvalidToLoc',          'us_english', 1871, 0, '237127 Invalid ToLoc'
execute rdt.rdtAddMsg 237128, 10, '237128^UpdRsnFail',            'us_english', 1871, 0, '237128 Update Reason Failed'
execute rdt.rdtAddMsg 237129, 10, '237129^HOLDFailed',            'us_english', 1871, 0, '237129 Create INVENTORYHOLD Data Failed'
execute rdt.rdtAddMsg 237130, 10, '237130^LocNotMatch',           'us_english', 1871, 0, '237130 Not allow to overwrite Loc in this category'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 237101 AND 237150