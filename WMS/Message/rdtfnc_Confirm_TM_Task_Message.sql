--rdtfnc_Confirm_TM_Task
rdt.rdtDropMsg 139901 , 139950

execute rdt.rdtAddMsg 139901, 10, '39901^GroupKey req',   'us_english', 1822
execute rdt.rdtAddMsg 139902, 10, '39902^No StorerKey',   'us_english', 1822
execute rdt.rdtAddMsg 139903, 10, '39903^NotInStorerGrp', 'us_english', 1822
execute rdt.rdtAddMsg 139904, 10, '39904^Upd Task Fail',  'us_english', 1822
execute rdt.rdtAddMsg 139905, 10, '39905^No Task To Cfm', 'us_english', 1822


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 139901 AND 139950