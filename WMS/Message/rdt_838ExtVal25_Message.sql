--rdt_838ExtVal25
--232151 - 232200
execute rdt.rdtdropmsg 232151, 232200

execute rdt.rdtAddMsg 232151, 10, '232151FromDropIDEmpty', 'us_english', 838, 0, '232151 Missing From Drop ID'
execute rdt.rdtAddMsg 232152, 10, '232152NeedBatchNo', 'us_english', 838, 0, '232152 Need Batch No'
execute rdt.rdtAddMsg 232153, 10, '232153WrongBatchNo', 'us_english', 838, 0, '232153 Wrong Batch No'
execute rdt.rdtAddMsg 232154, 10, '232154OverPack', 'us_english', 838, 0, '232154 Batch Qty Exceeded'
execute rdt.rdtAddMsg 232155, 10, '232155ChkPackData1Fail', 'us_english', 838, 0, '232155 Fail to check PackData1'
execute rdt.rdtAddMsg 232156, 10, '232156GetPickQtyFail', 'us_english', 838, 0, '232156 Fail to get PickQty'

select * from rdt.rdtmsg (nolock) where Message_ID between 232151 and 232200