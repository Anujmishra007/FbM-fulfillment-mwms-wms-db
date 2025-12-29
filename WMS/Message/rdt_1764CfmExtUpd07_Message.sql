--rdt_1764CfmExtUpd07
--254151 - 254200


execute rdt.rdtdropmsg 254151, 254200

execute rdt.rdtAddMsg 254151, 10, '254151 DelTaskFail',         'us_english', 1764, 0, '254151 Delete Task Fail'
execute rdt.rdtAddMsg 254152, 10, '254152 UpdPKDFail',          'us_english', 1764, 0, '254152 Update pickdetail Fail'
execute rdt.rdtAddMsg 254153, 10, '254153 UpdLLIFail',          'us_english', 1764, 0, '254153 Update LotxLocxID Fail'
execute rdt.rdtAddMsg 254154, 10, '254154 UpdLLIFail',          'us_english', 1764, 0, '254154 Update LotxLocxID Fail'
execute rdt.rdtAddMsg 254155, 10, '254155 SKUEmpty',            'us_english', 1764, 0, '254155 SKU is empty'
execute rdt.rdtAddMsg 254156, 10, '254156 UCCNoEmpty',          'us_english', 1764, 0, '254156 UCCNo is empty'
execute rdt.rdtAddMsg 254157, 10, '254157 WavekeyEmpty',        'us_english', 1764, 0, '254157 WaveKey is empty'
execute rdt.rdtAddMsg 254158, 10, '254158 NoQcmdConfig',        'us_english', 1764, 0, '254158 Qcmd config is not found'
execute rdt.rdtAddMsg 254159, 10, '254159 GenQcmdFail',         'us_english', 1764, 0, '254159 SubmitQcmd SQL Error'
execute rdt.rdtAddMsg 254160, 10, '254160 GenQcmdFail',         'us_english', 1764, 0, '254160 Failed to submit Qcmd task'
execute rdt.rdtAddMsg 254161, 10, '254161 InvalidSPName',       'us_english', 1764, 0, '254160 Invalid SP Name'
execute rdt.rdtAddMsg 254162, 10, '254162 UpdLLIFail',          'us_english', 1764, 0, '254162 Update QtyReplen Fail'
execute rdt.rdtAddMsg 254163, 10, '254163 UpdTaskFail',         'us_english', 1764, 0, '254163 Update Task Fail'
execute rdt.rdtAddMsg 254164, 10, '254164 HoldInvFail',         'us_english', 1764, 0, '254164 Hold Inventory Fail'
execute rdt.rdtAddMsg 254165, 10, '254165 HoldInvFail',         'us_english', 1764, 0, '254165 Hold Inventory Fail'
execute rdt.rdtAddMsg 254166, 10, '254166 PartialShort',        'us_english', 1764, 0, '254166 Not allow to partial short'
execute rdt.rdtAddMsg 254167, 10, '254167 UpdLLIFail',          'us_english', 1764, 0, '254167 Update QtyReplen Fail'


select * from rdt.rdtmsg (nolock) where message_id between 254151 and 254200