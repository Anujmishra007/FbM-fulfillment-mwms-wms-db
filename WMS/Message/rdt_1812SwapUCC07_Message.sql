--rdt_1812SwapUCC07
execute rdt.rdtDropMsg 276901, 276950

execute rdt.rdtAddMsg 276901, 10, '276901^BadTaskDtlKey',      'us_english', 1878, 0, '276901: Task detail key not found'
execute rdt.rdtAddMsg 276902, 10, '276902^InvNotFound',        'us_english', 1878, 0, '276902: Inventory not found for task case'
execute rdt.rdtAddMsg 276903, 10, '276903^MixSKULot.Task',     'us_english', 1878, 0, '276903: Cannot swap case with mix SKU/Lot '
execute rdt.rdtAddMsg 276904, 10, '276904^TaskLotSKUEmpty',    'us_english', 1878, 0, '276904: Task LOT or SKU is empty'
execute rdt.rdtAddMsg 276905, 10, '276905^InvalidCaseID',      'us_english', 1878, 0, '276905: Invalid CaseID - not found in inventory'
execute rdt.rdtAddMsg 276906, 10, '276906^MixSKULot.Act',      'us_english', 1878, 0, '276906: Cannot swap case with mix SKU/Lot'
execute rdt.rdtAddMsg 276907, 10, '276907^CasePicked',         'us_english', 1878, 0, '276907: Case is already picked'
execute rdt.rdtAddMsg 276908, 10, '276908^SKUMismatch',        'us_english', 1878, 0, '276908: SKU mismatch'
execute rdt.rdtAddMsg 276909, 10, '276909^CasePartialAlloc',   'us_english', 1878, 0, '276909: Case is partially allocated'
execute rdt.rdtAddMsg 276910, 10, '276910^QTYMismatch',        'us_english', 1878, 0, '276910: QTY mismatch'
execute rdt.rdtAddMsg 276911, 10, '276911^ActTaskNotFound',    'us_english', 1878, 0, '276911: Act case task detail not found'
execute rdt.rdtAddMsg 276912, 10, '276912^ActTaskStatus',      'us_english', 1878, 0, '276912: Act case task status is invalid'
execute rdt.rdtAddMsg 276913, 10, '276913^ActTaskNotUOM2',     'us_english', 1878, 0, '276913: Act case task is not UOM 2'
execute rdt.rdtAddMsg 276914, 10, '276914^ActTaskQTYMismatch', 'us_english', 1878, 0, '276914: Act case task QTY does not match allocated QTY'
execute rdt.rdtAddMsg 276915, 10, '276915^ActCasePicked',      'us_english', 1878, 0, '276915: Act case pick detail is already picked'
execute rdt.rdtAddMsg 276916, 10, '276916^UpdPKDtlFail',       'us_english', 1878, 0, '276916: Failed to unallocate task case'
execute rdt.rdtAddMsg 276917, 10, '276917^UpdPKDtlFail',       'us_english', 1878, 0, '276917: Failed to unallocate act case'
execute rdt.rdtAddMsg 276918, 10, '276918^UpdPKDtlFail',       'us_english', 1878, 0, '276918: Failed to reallocate task case'
execute rdt.rdtAddMsg 276919, 10, '276919^UpdPKDtlFail',       'us_english', 1878, 0, '276919: Failed to reallocate act case'
execute rdt.rdtAddMsg 276920, 10, '276920^UpdTskDtlFail',      'us_english', 1878, 0, '276920: Failed to update task case task'
execute rdt.rdtAddMsg 276921, 10, '276921^UpdTskDtlFail',      'us_english', 1878, 0, '276921: Failed to update act case task'
--execute rdt.rdtAddMsg 276922, 10, '276922^CannotSwapUCC',      'us_english', 1878, 0, '276922: Cannot swap UCC'
execute rdt.rdtAddMsg 276923, 10, '276923^InsSwapUCCFail',     'us_english', 1878, 0, '276923: Failed to insert into rdt.SwapUCC'
execute rdt.rdtAddMsg 276924, 10, '276924^FromIDMismatch',     'us_english', 1878, 0, '276924: FromID mismatch'

select * from rdt.rdtmsg (nolock) where message_id between 276901 and 276950
