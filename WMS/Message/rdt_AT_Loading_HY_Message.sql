--rdt_AT_Loading_HY
--FCR-13166
execute rdt.rdtDropMsg 278101, 278150

execute rdt.rdtAddMsg 278101, 10, '278101CtrNotChkIN   ', 'us_english', 652, 0, '278101 Container Not Checked IN'
execute rdt.rdtAddMsg 278102, 10, '278102UnloadNotStart', 'us_english', 652, 0, '278102 Unloading Not Started'
execute rdt.rdtAddMsg 278103, 10, '278103InvContNo     ', 'us_english', 652, 0, '278103 Invalid Container No'
execute rdt.rdtAddMsg 278104, 10, '278104InvStatus     ', 'us_english', 652, 0, '278104 Invalid Status for unloading start/end'
execute rdt.rdtAddMsg 278105, 10, '278105InsVasFail    ', 'us_english', 652, 0, '278105 Insert VAS Details Failed'
execute rdt.rdtAddMsg 278106, 10, '278106UpdRecptFail  ', 'us_english', 652, 0, '278106 Update Receipt Failed'
execute rdt.rdtAddMsg 278107, 10, '278107InvColumn     ', 'us_english', 652, 0, '278107 Invalid Table Column'
execute rdt.rdtAddMsg 278108, 10, '278108InvColumn     ', 'us_english', 652, 0, '278108 Info can not be empty'
execute rdt.rdtAddMsg 278109, 10, '278109InvFormat     ', 'us_english', 652, 0, '278109 Invalid Format'
execute rdt.rdtAddMsg 278110, 10, '278110InvColumn     ', 'us_english', 652, 0, '278110 Info can not be empty'
execute rdt.rdtAddMsg 278111, 10, '278111InvFormat     ', 'us_english', 652, 0, '278111 Invalid Format'
execute rdt.rdtAddMsg 278112, 10, '278112InvColumn     ', 'us_english', 652, 0, '278112 Info can not be empty'
execute rdt.rdtAddMsg 278113, 10, '278113InvFormat     ', 'us_english', 652, 0, '278113 Invalid Format'
execute rdt.rdtAddMsg 278114, 10, '278114InvColumn     ', 'us_english', 652, 0, '278114 Info can not be empty'
execute rdt.rdtAddMsg 278115, 10, '278115InvFormat     ', 'us_english', 652, 0, '278115 Invalid Format'
execute rdt.rdtAddMsg 278116, 10, '278116InvFormat     ', 'us_english', 652, 0, '278116 Invalid Format'
execute rdt.rdtAddMsg 278117, 10, '278117InsVasFail    ', 'us_english', 652, 0, '278117 Insert VAS Details Failed'
execute rdt.rdtAddMsg 278118, 10, '278118UpdRecptFail  ', 'us_english', 652, 0, '278118 Update Receipt Failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 278101 AND 278150
