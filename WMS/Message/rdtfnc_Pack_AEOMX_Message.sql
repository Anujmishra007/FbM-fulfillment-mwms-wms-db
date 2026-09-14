-- rdtfnc_Pack_AEOMX
--Re-use some error messages from 838

--The following is the new error message for 994
execute rdt.rdtDropMsg 280701, 280750

execute rdt.rdtAddMsg 280701, 10, '280701^ScanPSNO',       'us_english', 994, 0, '280701: Must scan PickSlipNo'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 280701 and 280750 AND lang_code = 'ENG'



