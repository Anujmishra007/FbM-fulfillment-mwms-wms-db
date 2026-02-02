
--isp_TPS_ExtGenLBL01
exec API.TouchPadDropMsg 1000351 , 1000400

execute API.TouchPadAddMsg 1000351, 10, 'NO TRACKING NO. Function : isp_TPS_ExtGenLBL01',    'us_english'
execute API.TouchPadAddMsg 1000352, 10, 'Insert CartonTrack table fail Function : isp_TPS_ExtGenLBL01',    'us_english'
execute API.TouchPadAddMsg 1000353, 10, 'DEL TRACK# Function : isp_TPS_ExtGenLBL01',    'us_english'
execute API.TouchPadAddMsg 1000354, 10, 'Need LabelNo. Function : isp_TPS_ExtGenLBL01',    'us_english'
execute API.TouchPadAddMsg 1000355, 10, 'Execution Error : Vat is not a numeric value. Function : isp_TPS_ExtGenLBL01',    'us_english'
execute API.TouchPadAddMsg 1000356, 10, 'Failed to get the LabelNo from sub SP api.isp_TP_GenLabelNo_Wrapper. Function : isp_TPS_ExtGenLBL01',    'us_english'
execute API.TouchPadAddMsg 1000357, 10, 'Failed to get the LabelNo from sub SP api.isp_TP_GenSSCCLabel_Wrapper. Function : isp_TPS_ExtGenLBL01',    'us_english'