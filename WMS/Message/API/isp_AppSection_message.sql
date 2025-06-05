--isp_AppSection
exec API.TouchPadDropMsg 1000801 , 1000850

execute API.TouchPadAddMsg 1000801, 10, '1000801 Insufficient parameter for application process execution. Function : isp_AppSection',    'us_english'
execute API.TouchPadAddMsg 1000802, 10, '1000802 Error in executing nspGetRight. Function : isp_AppSection',    'us_english'
execute API.TouchPadAddMsg 1000803, 10, '1000803 User login in another device. Please logout from previous device before login in this device. Function : isp_AppSection',    'us_english'
execute API.TouchPadAddMsg 1000804, 10, '1000804 The scanned document ID is process by another user. Please use another document ID. Function : isp_AppSection',    'us_english'
execute API.TouchPadAddMsg 1000805, 10, '1000805 Other user login to this device. Please ensure no other user login in this device before proceed to login. Function : isp_AppSection',    'us_english'
execute API.TouchPadAddMsg 1000806, 10, '1000806 User found login in another device. Please logout from previous device before proceed to login in this device. Function : isp_AppSection',    'us_english'