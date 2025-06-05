
--isp_TPS_ExtGenLBL02
exec API.TouchPadDropMsg 1001551 , 1001600

execute API.TouchPadAddMsg 1001551, 10, 'NO TRACKING #|isp_TPS_ExtGenLBL02                                           ',    'us_english'
execute API.TouchPadAddMsg 1001552, 10, 'Insert CartonTrack table fail :isp_TPS_ExtGenLBL02                          ',    'us_english'
execute API.TouchPadAddMsg 1001553, 10, 'DEL TRACK# Err:isp_TPS_ExtGenLBL02                                          ',    'us_english'
execute API.TouchPadAddMsg 1001554, 10, 'Need LabelNo. Function : isp_TPS_ExtGenLBL02                                ',    'us_english'
execute API.TouchPadAddMsg 1001555, 10, 'Execution Error : Vat is not a numeric value. Function : isp_TPS_ExtGenLBL02',    'us_english'