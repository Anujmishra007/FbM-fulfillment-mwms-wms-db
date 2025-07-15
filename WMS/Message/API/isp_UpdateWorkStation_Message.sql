

--isp_UpdateWorkstation
exec API.TouchPadDropMsg 1000401 , 1000450

execute API.TouchPadAddMsg 1000401, 10, 'Unable to retrieve Workstation ID. Function : isp_UpdateWorkstation',    'us_english'
execute API.TouchPadAddMsg 1000402, 10, 'Unable to retrieve Device ID. Function : isp_UpdateWorkstation',    'us_english'
execute API.TouchPadAddMsg 1000403, 10, 'Fail to update into Workstation. Function : isp_UpdateWorkstation',    'us_english'
execute API.TouchPadAddMsg 1000404, 10, 'The selected workstation already been in use by another user, kindly re-select a new one. Function : isp_UpdateWorkstation',    'us_english'
execute API.TouchPadAddMsg 1000405, 10, 'Invalid setup. This device has been assigned to a workstation. Function : isp_UpdateWorkstation','us_english'
execute API.TouchPadAddMsg 1000406, 10, 'Fail to update into Workstation. Function : isp_UpdateWorkstation','us_english'
execute API.TouchPadAddMsg 1000407, 10, 'Invalid Workstation. Please use other Workstation. Function : isp_UpdateWorkstation','us_english'