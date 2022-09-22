
-- Cycle Count Messages
-- ********************

-- rdtfnc_CycleCount (range1: 62081 - 62160, range2: 66816 - 66850)
-- execute rdt.rdtDropMsg 62081, 62160
-- select * from rdt.rdtMsg (nolock) where message_id between 62081 and 62160

-- execute rdt.rdtDropMsg 66816, 66850
-- select * from rdt.rdtMsg (nolock) where message_id between 66816 and 66850

-- SOS254689
-- execute rdt.rdtDropMsg 77701, 77750

execute rdt.rdtAddMsg 62081, 10, '62081 CCREF required', 'us_english'
execute rdt.rdtAddMsg 62082, 10, '62082 Invalid CCREF', 'us_english'
execute rdt.rdtAddMsg 62083, 10, '62083 Setup CCREF', 'us_english'
execute rdt.rdtAddMsg 62084, 10, '62084 SHEET required', 'us_english'
execute rdt.rdtAddMsg 62085, 10, '62085 Invalid SHEET', 'us_english'
execute rdt.rdtAddMsg 62086, 10, '62086 CNT NO required', 'us_english'
execute rdt.rdtAddMsg 62087, 10, '62087 Invalid CNT NO', 'us_english'
execute rdt.rdtAddMsg 62088, 10, '62088 Finalized Cnt3', 'us_english'
execute rdt.rdtAddMsg 62089, 10, '62089 Wrong CNT NO', 'us_english'
--execute rdt.rdtAddMsg 62090, 10, '62090 LOC Not Found', 'us_english'
execute rdt.rdtAddMsg 62091, 10, '62091 Last LOC', 'us_english'
-- Not allow to overwrite suggested LOC
execute rdt.rdtAddMsg 62092, 10, '62092 LOC Not Match', 'us_english'
-- execute rdt.rdtAddMsg 62092, 10, '62092 LOC Not Found', 'us_english'
-- execute rdt.rdtAddMsg 62093, 10, '62093 Facility Diff', 'us_english'
-- execute rdt.rdtAddMsg 62094, 10, '62094 Setup LogiLOC', 'us_english'
execute rdt.rdtAddMsg 62093, 10, '62093 Option required', 'us_english'
execute rdt.rdtAddMsg 62094, 10, '62094 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 62095, 10, '62095 No UCCConfig', 'us_english'
execute rdt.rdtAddMsg 62096, 10, '62096 LocType PICK', 'us_english'
execute rdt.rdtAddMsg 62097, 10, '62097 LOC No Rec', 'us_english'
-- execute rdt.rdtAddMsg 62097, 10, '62097 LOC, ID No Rec', 'us_english'
-- execute rdt.rdtAddMsg 62099, 10, '62099 ID required', 'us_english'
execute rdt.rdtAddMsg 62098, 10, '62098 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 62099, 10, '62099 UCC StorerDiff', 'us_english'
execute rdt.rdtAddMsg 62100, 10, '62100 No UCC (CCDet)', 'us_english'
execute rdt.rdtAddMsg 62101, 10, '62101 Double scan', 'us_english'
execute rdt.rdtAddMsg 62102, 10, '62102 Scanned (New)', 'us_english' 
execute rdt.rdtAddMsg 62103, 10, '62103 UCC needed', 'us_english'
execute rdt.rdtAddMsg 62104, 10, '62104 UCC Status bad', 'us_english'
execute rdt.rdtAddMsg 62105, 10, '62105 Double scan', 'us_english'
execute rdt.rdtAddMsg 62106, 10, '62106 Scanned (New)', 'us_english'
execute rdt.rdtAddMsg 62107, 10, '62107 UCC Not Found', 'us_english'
-- execute rdt.rdtAddMsg 62110, 10, '62110 Setup CaseCnt', 'us_english'
execute rdt.rdtAddMsg 62108, 10, '62108 Lottable1 req', 'us_english'
execute rdt.rdtAddMsg 62109, 10, '62109 Lottable2 req', 'us_english'
-- SOS57609 JulianDate Lottables
-- execute rdt.rdtAddMsg 62110, 10, '62110 JulianDate Err', 'us_english'

execute rdt.rdtAddMsg 62111, 10, '62111 Lottable3 req', 'us_english'
execute rdt.rdtAddMsg 62112, 10, '62112 Lottable4 req', 'us_english'
execute rdt.rdtAddMsg 62113, 10, '62113 Invalid date', 'us_english'
execute rdt.rdtAddMsg 62114, 10, '62114 Lottable5 req', 'us_english'
execute rdt.rdtAddMsg 62115, 10, '62115 Invalid date', 'us_english'
execute rdt.rdtAddMsg 62116, 10, '62116 End of LOC Rec', 'us_english'
-- execute rdt.rdtAddMsg 62116, 10, '62116 End of Record', 'us_english'
execute rdt.rdtAddMsg 62117, 10, '62117 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 62118, 10, '62118 Blank record', 'us_english'
execute rdt.rdtAddMsg 62119, 10, '62119 SKU/UPC req', 'us_english'
execute rdt.rdtAddMsg 62120, 10, '62120 Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 62121, 10, '62121 SKU Not Found', 'us_english'
execute rdt.rdtAddMsg 62122, 10, '62122 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 62123, 10, '62123 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 62124, 10, '62124 Zero CaseCnt', 'us_english'
execute rdt.rdtAddMsg 62125, 10, '62125 QTY required', 'us_english'
execute rdt.rdtAddMsg 62126, 10, '62126 Lottable1 req', 'us_english'
execute rdt.rdtAddMsg 62127, 10, '62127 Lottable2 req', 'us_english'
-- SOS57609 JulianDate Lottables
-- execute rdt.rdtAddMsg 62128, 10, '62128 JulianDate Err', 'us_english'

execute rdt.rdtAddMsg 62129, 10, '62129 Lottable3 req', 'us_english'
execute rdt.rdtAddMsg 62130, 10, '62130 Lottable4 req', 'us_english'
execute rdt.rdtAddMsg 62131, 10, '62131 Invalid date', 'us_english'
execute rdt.rdtAddMsg 62132, 10, '62132 Lottable5 req', 'us_english'
execute rdt.rdtAddMsg 62133, 10, '62133 Invalid date', 'us_english'
execute rdt.rdtAddMsg 62134, 10, '62134 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 62135, 10, '62135 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 62136, 10, '62136 Zero CaseCnt', 'us_english'


/************************************************************************************/
/* SOS128449 & 133966 Enchancement (MaryVong01) - START                             */
/************************************************************************************/
-- Screen 2. SheetNo_Or_Criterias
execute rdt.rdtAddMsg 62137, 10, '62137 Sheet/Criteria', 'us_english'
execute rdt.rdtAddMsg 62138, 10, '62138 Wrong Zone', 'us_english'
execute rdt.rdtAddMsg 62139, 10, '62139 Blank record', 'us_english'
execute rdt.rdtAddMsg 62140, 10, '62140 ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 66835, 10, '66835 Blank record', 'us_english'

-- Screen 3. CountNo
--execute rdt.rdtAddMsg 62141, 10, '62141 ReleaseMobFail', 'us_english'

-- Screen 4. LOC
execute rdt.rdtAddMsg 62142, 10, '62142 Facility Diff', 'us_english'
execute rdt.rdtAddMsg 62143, 10, '62143 Setup LogiLOC', 'us_english'
execute rdt.rdtAddMsg 62144, 10, '62144 LOC Not Found', 'us_english'

-- Screen 4a. LOC - Option
execute rdt.rdtAddMsg 62145, 10, '62145 Option req', 'us_english'
execute rdt.rdtAddMsg 62146, 10, '62146 Invalid Option', 'us_english'

-- Screen 4b. Last LOC - Option
execute rdt.rdtAddMsg 62147, 10, '62147 Option req', 'us_english'
execute rdt.rdtAddMsg 62148, 10, '62148 Invalid Option', 'us_english'

-- Screen 4c. Re-Count LOC - Option
execute rdt.rdtAddMsg 62149, 10, '62149 Option req', 'us_english'
execute rdt.rdtAddMsg 62150, 10, '62150 Invalid Option', 'us_english'

-- Screen 5. ID
execute rdt.rdtAddMsg 62151, 10, '62151 ID No Rec', 'us_english'
execute rdt.rdtAddMsg 62152, 10, '62152 Blank SKU', 'us_english'
--execute rdt.rdtAddMsg 62153, 10, '62153 LOCIDLocked', 'us_english'

-- Screen 10. SKU
execute rdt.rdtAddMsg 62154, 10, '62154 End of ID Rec', 'us_english'
execute rdt.rdtAddMsg 62155, 10, '62155 Blank SKU', 'us_english'

-- Screen 15. SINGLE SKU - Sku Scan
execute rdt.rdtAddMsg 62156, 10, '62156 SKU/UPC req', 'us_english'
execute rdt.rdtAddMsg 62157, 10, '62157 Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 62158, 10, '62158 SKU Not Found', 'us_english'
--execute rdt.rdtAddMsg 62159, 10, '62159 SKU Not Found', 'us_english'
execute rdt.rdtAddMsg 62160, 10, '62160 SKU In Use', 'us_english'
--execute rdt.rdtAddMsg 66816, 10, '66816 LOCIDSKULocked', 'us_english'

-- Screen 16. SINGLE SKU - Add Lottables
execute rdt.rdtAddMsg 66817, 10, '66817 Lottable1 req', 'us_english'
execute rdt.rdtAddMsg 66818, 10, '66818 Lottable2 req', 'us_english'
execute rdt.rdtAddMsg 66819, 10, '66819 Lottable3 req', 'us_english'
execute rdt.rdtAddMsg 66820, 10, '66820 Lottable4 req', 'us_english'
execute rdt.rdtAddMsg 66821, 10, '66821 Invalid date', 'us_english'
execute rdt.rdtAddMsg 66822, 10, '66822 Lottable5 req', 'us_english'
execute rdt.rdtAddMsg 66823, 10, '66823 Invalid date', 'us_english'
--execute rdt.rdtAddMsg 66824, 10, '66824 LOCIDLocked', 'us_english'
--execute rdt.rdtAddMsg 66825, 10, '66825 LOCIDSKULocked', 'us_english'

-- Screen 17. SINGLE SKU - Increase QTY
execute rdt.rdtAddMsg 66826, 10, '66826 SKU/UPC req', 'us_english'
execute rdt.rdtAddMsg 66827, 10, '66827 Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 66828, 10, '66828 SKU Not Found', 'us_english'
execute rdt.rdtAddMsg 66829, 10, '66829 SKU Not Found', 'us_english'
--execute rdt.rdtAddMsg 66830, 10, '66830 LOCIDSKULocked', 'us_english'
execute rdt.rdtAddMsg 66831, 10, '66831 SKU Not Found', 'us_english'

-- Screen 18. SINGLE SKU - Option
execute rdt.rdtAddMsg 66832, 10, '66832 Option req', 'us_english'
execute rdt.rdtAddMsg 66833, 10, '66833 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 66834, 10, '66834 No LotLabel', 'us_english'

execute rdt.rdtAddMsg 66835, 10, '66835^Blank Record', 'us_english'

execute rdt.rdtAddMsg 66836, 10, '66836^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 66837, 10, '66837^Invalid Option', 'us_english'

-- SOS166769 (james05)
execute rdt.rdtAddMsg 66838, 10, '66838^Blank Record',   'us_english'
execute rdt.rdtAddMsg 66839, 10, '66839^Blank Record',   'us_english'
execute rdt.rdtAddMsg 66840, 10, '66840^Blank Record',   'us_english'
execute rdt.rdtAddMsg 66841, 10, '66841^LOC is Locked',  'us_english'

-- SOS201672
execute rdt.rdtAddMsg 66842, 10, '66842^INV SKUDEF UOM',  'us_english'
execute rdt.rdtAddMsg 66843, 10, '66843^CONV FAIL',  'us_english'
execute rdt.rdtAddMsg 66844, 10, '66844^INV SKUDEF UOM',  'us_english'
execute rdt.rdtAddMsg 66845, 10, '66845^INV Qty',  'us_english'
execute rdt.rdtAddMsg 66846, 10, '66846^INV Qty',  'us_english'
execute rdt.rdtAddMsg 66847, 10, '66847^INV Qty',  'us_english'

-- range 66816 - 66850, max msg id used = 66835

-------------------------------------------------------------------------------------
-- rdt_CycleCount_ConfirmSingleScan (range 66851 - 66875)
-- execute rdt.rdtDropMsg 66851, 66875
-- select * from rdt.rdtMsg (nolock) where message_id between 66851 and 66875

execute rdt.rdtAddMsg 66851, 10, '66851 UPDCCLockFail', 'us_english'
execute rdt.rdtAddMsg 66852, 10, '66852 UPDCCLockFail', 'us_english'

--------------------------------------------------------------------------------------
-- rdt_CycleCount_InsertCCLock (range 66876 - 66900)
-- execute rdt.rdtDropMsg 66876, 66900
-- select * from rdt.rdtMsg (nolock) where message_id between 66876 and 66900

execute rdt.rdtAddMsg 66876, 10, '66876 ADDCCLockFail', 'us_english'

/************************************************************************************/
/* SOS128449 & 133966 Enchancement (MaryVong01) - END                               */
/************************************************************************************/


-------------------------------------------------------------------------------------
-- rdtfnc_CycleCount_InsertCCDetail (range 62161 - 62165)
-- execute rdt.rdtDropMsg 62161, 62165
-- select * from rdt.rdtMsg (nolock) where message_id between 62161 and 62165

execute rdt.rdtAddMsg 62161, 10, '62161 GetDetKey fail', 'us_english'
execute rdt.rdtAddMsg 62162, 10, '62162 Add CCDET fail', 'us_english'

-------------------------------------------------------------------------------------
-- rdtfnc_CycleCount_UpdateCCDetail (range 62166 - 62170)
-- execute rdt.rdtDropMsg 62166, 62170
-- select * from rdt.rdtMsg (nolock) where message_id between 62166 and 62170

execute rdt.rdtAddMsg 62166, 10, '62166 Upd CCDET fail', 'us_english'
execute rdt.rdtAddMsg 62167, 10, '62167 Upd CCDET fail', 'us_english'
execute rdt.rdtAddMsg 62168, 10, '62168 Upd CCDET fail', 'us_english'


-------------------------------------------------------------------------------------

--SOS254689
execute rdt.rdtAddMsg 77701, 10, '77701^ID Required',     'us_english'
execute rdt.rdtAddMsg 77702, 10, '77702^LOC LOSEID',      'us_english'
execute rdt.rdtAddMsg 77703, 10, '77703^CTN COUNT Req',   'us_english'
execute rdt.rdtAddMsg 77704, 10, '77704^BAD CTN COUNT',   'us_english'
execute rdt.rdtAddMsg 77705, 10, '77705^NO CCD FOUND',    'us_english'
execute rdt.rdtAddMsg 77706, 10, '77706^ID NO RECORD',    'us_english'
execute rdt.rdtAddMsg 77707, 10, '77707^INV COUNT TYPE',  'us_english'
execute rdt.rdtAddMsg 77708, 10, '77708^INV COUNT TYPE',  'us_english'
execute rdt.rdtAddMsg 77709, 10, '77709^INV COUNT TYPE',  'us_english'
execute rdt.rdtAddMsg 77710, 10, '77710^MARK CTN FAIL',   'us_english'
execute rdt.rdtAddMsg 77711, 10, '77711^PLS CFM LOC',     'us_english'
execute rdt.rdtAddMsg 77712, 10, '77712^EDT NOT ALLOW',   'us_english'
execute rdt.rdtAddMsg 77713, 10, '77713^LOC REQUIRED',    'us_english'

--SOS289160
--rdt.rdtDropMsg 77714, 77714
execute rdt.rdtAddMsg 77714, 10, '77714^RESET CNT FAIL',  'us_english'



-- reuse msg since not in use in script SOS254690
--rdt.rdtDropMsg 62090, 62090
execute rdt.rdtAddMsg 62090, 10, '62090^ALL COUNT DONE', 'us_english'

-- continue from message id 77714 SOS302894
execute rdt.rdtAddMsg 77715, 10, '77715^INVALID SKU',   'us_english'
execute rdt.rdtAddMsg 77716, 10, '77716^INVALID LOT01', 'us_english'
execute rdt.rdtAddMsg 77717, 10, '77717^INVALID LOT02', 'us_english'
execute rdt.rdtAddMsg 77718, 10, '77718^INVALID LOT03', 'us_english'
execute rdt.rdtAddMsg 77719, 10, '77719^INVALID LOT04', 'us_english'

-- SOS303558
execute rdt.rdtAddMsg 77720, 10, '77720^QTY COUNTED=0',  'us_english'

-- (ChewKP03)
execute rdt.rdtAddMsg 77721, 10, '77721^AllLocCounted',  'us_english'

-- SOS375049
execute rdt.rdtAddMsg 77722, 10, '77722^UpdCounterFail',  'us_english'
execute rdt.rdtAddMsg 77723, 10, '77723^UpdCCDtlFail',    'us_english'
execute rdt.rdtAddMsg 77724, 10, '77724^UpdCounterFail',  'us_english'
execute rdt.rdtAddMsg 77725, 10, '77725^UpdCCDtlFail',    'us_english'

-- WMS9681
execute rdt.rdtAddMsg 77726, 10, '77726^Invalid Format',  'us_english'

-- WMS-11865
execute rdt.rdtAddMsg 77727, 10, '77727^Last LOC',        'us_english'
execute rdt.rdtAddMsg 77728, 10, '77728^Last LOC',        'us_english'

-- WMS-20691
execute rdt.rdtAddMsg 77729, 10, '77729^Opt Not Allow',   'us_english'
execute rdt.rdtAddMsg 77730, 10, '77730^Invalid Qty',     'us_english'
execute rdt.rdtAddMsg 77731, 10, '77731^Invalid Qty',     'us_english'
execute rdt.rdtAddMsg 77732, 10, '77732^Enter X Allow',   'us_english'
execute rdt.rdtAddMsg 77734, 10, '77734^Invalid Qty',     'us_english'
