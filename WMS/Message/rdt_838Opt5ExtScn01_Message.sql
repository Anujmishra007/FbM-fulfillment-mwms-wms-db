--rdt_838Opt5ExtScn01_Message
--FCR-2495
exec rdt.rdtdropmsg 234151, 234200

execute rdt.rdtAddMsg 234151, 10, '234151CdLKUPNotFound', 'us_english', 838
execute rdt.rdtAddMsg 234152, 10, '234152NeedIDOrSKU', 'us_english', 838
execute rdt.rdtAddMsg 234153, 10, '234153MultiSKUOrLOT', 'us_english', 838
execute rdt.rdtAddMsg 234154, 10, '234154Pallet does not exist for the scanned PS No', 'us_english', 838
execute rdt.rdtAddMsg 234155, 10, '234155NOT Full Pallet', 'us_english', 838
execute rdt.rdtAddMsg 234156, 10, '^234156Pallet in {} status', 'us_english', 838
execute rdt.rdtAddMsg 234157, 10, '234157Only input either Pallet ID or SKU, not both', 'us_english', 838
execute rdt.rdtAddMsg 234158, 10, '234158Fully Packed', 'us_english', 838
execute rdt.rdtAddMsg 234159, 10, '234159Update Pickdetail Failed', 'us_english', 838
execute rdt.rdtAddMsg 234160, 10, '234160PleaseEnterQty', 'us_english', 838
execute rdt.rdtAddMsg 234161, 10, '234161SKU/Batch does not exist in the scanned PSNo', 'us_english', 838
execute rdt.rdtAddMsg 234162, 10, '234162No Cases of SKU', 'us_english', 838
execute rdt.rdtAddMsg 234163, 10, '234163Case not in picked status', 'us_english', 838
execute rdt.rdtAddMsg 234164, 10, '234164MutliPickdetailLinesForThisPallet', 'us_english', 838
execute rdt.rdtAddMsg 234165, 10, '234165SplitPickDetailFailed', 'us_english', 838
execute rdt.rdtAddMsg 234166, 10, '234166UPDATEPickDetailFailed', 'us_english', 838
execute rdt.rdtAddMsg 234167, 10, '234167InsertTranslogFailed', 'us_english', 838
execute rdt.rdtAddMsg 234168, 10, '234168CaseQtyIsMoreThanPicked', 'us_english', 838
execute rdt.rdtAddMsg 234169, 10, '234169PleaseEnterQtyLessThan{}', 'us_english', 838
execute rdt.rdtAddMsg 234170, 10, '234170MultiBatchExist,InputBatch', 'us_english', 838




select * from rdt.rdtmsg (nolock) where message_id between 234151 AND 234200

