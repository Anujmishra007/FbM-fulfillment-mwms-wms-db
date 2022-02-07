-- rdtfnc_TotePick_ConfirmTask
-- execute rdt.rdtDropMsg 90101 - 90150 

DECLARE @nFunc INT

SET @nFunc = 1809

execute rdt.rdtAddMsg 90116, 10, '90116^GetDetKey Fail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90117, 10, '90117^InstPKHdr Fail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90118, 10, '90118^Scan In Fail',   'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90119, 10, '90119^UpdPickDetailFail', 'us_english' ,@nFunc
execute rdt.rdtAddMsg 90120, 10, '90120^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90121, 10, '90121^GetDetKeyFail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90122, 10, '90122^Ins PDtl Fail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90123, 10, '90123^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90124, 10, '90124^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90125, 10, '90125^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90126, 10, '90126^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90127, 10, '90127^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90128, 10, '90128^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90129, 10, '90129^GetDetKeyFail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90130, 10, '90130^Ins PDtl Fail',  'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90131, 10, '90131^SEE_SUPERVISOR', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90132, 10, '90132^SEE_SUPERVISOR', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90133, 10, '90133^OffSetPDtlFail', 'us_english'    ,@nFunc
execute rdt.rdtAddMsg 90134, 10, '90134^OffSetPDtlFail', 'us_english'    ,@nFunc

select * from rdt.rdtmsg (nolock) where message_id between 90101 and 90150