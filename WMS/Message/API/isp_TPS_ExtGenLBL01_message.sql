
--isp_TPS_ExtGenLBL01
exec API.TouchPadDropMsg 1000351 , 1000400

execute API.TouchPadAddMsg 1000351, 10, 'NO TRACKING #|isp_TPS_ExtGenLBL01                                           ',    'us_english'
execute API.TouchPadAddMsg 1000352, 10, 'Insert CartonTrack table fail :isp_TPS_ExtGenLBL01                          ',    'us_english'
execute API.TouchPadAddMsg 1000353, 10, 'DEL TRACK# Err:isp_TPS_ExtGenLBL01                                          ',    'us_english'
execute API.TouchPadAddMsg 1000354, 10, 'Need LabelNo. Function : isp_TPS_ExtGenLBL01                                ',    'us_english'
execute API.TouchPadAddMsg 1000355, 10, 'Execution Error : Vat is not a numeric value. Function : isp_TPS_ExtGenLBL01',    'us_english'