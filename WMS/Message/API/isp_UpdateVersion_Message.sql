

--isp_UpdateVersion
exec API.TouchPadDropMsg 1001751, 1001800

execute API.TouchPadAddMsg 1001751, 10, 'Unable to retrieve Workstation ID. Function : isp_UpdateVersion',    'us_english'
execute API.TouchPadAddMsg 1001752, 10, 'Unable to retrieve Device ID. Function : isp_UpdateVersion',    'us_english'
execute API.TouchPadAddMsg 1001753, 10, 'Invalid setup. This device has been assigned to a workstation. Function : isp_UpdateVersion',    'us_english'
execute API.TouchPadAddMsg 1001754, 10, 'Fail to update into Workstation. Function : isp_UpdateVersion',    'us_english'
execute API.TouchPadAddMsg 1001755, 10, 'Invalid Workstation. Please use other Workstation. Function : isp_UpdateVersion','us_english'