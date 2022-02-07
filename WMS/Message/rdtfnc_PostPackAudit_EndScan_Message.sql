/*
   60801 - 60805   rdtfnc_PostPackAudit_EndScan (screen)
   60806 - 60825   rdt_PostPackAudit_EndScan    (business logic)
   67051 - 67100   (continue for rdt_PostPackAudit_EndScan)
*/

-- rdtfnc_PostPackAudit_EndScan (range 60801 - 60805)
execute rdt.rdtAddMsg 60801, 10, '60801 Invalid option', 'us_english'
execute rdt.rdtAddMsg 60802, 10, '60802 No open pallet', 'us_english'
execute rdt.rdtAddMsg 60803, 10, '60803 Invalid option', 'us_english'
execute rdt.rdtAddMsg 60804, 10, '60804 No open case', 'us_english'

-- rdt_PostPackAudit_EndScan (range 60806 - 60825)
-- Existing
execute rdt.rdtAddMsg 60806, 10, '60806 UPD PKDtl fail', 'us_english'
execute rdt.rdtAddMsg 60807, 10, '60807 INS CALoad fail', 'us_english'
execute rdt.rdtAddMsg 60808, 10, '60808 Insert CSAudit_Load fail', 'us_english'

-- SOS139575
--execute rdt.rdtAddMsg 60809, 10, '60809 Insert CSAudit_Load fail', 'us_english'
execute rdt.rdtAddMsg 60809, 10, '60809 NoOpenedBatch', 'us_english'

execute rdt.rdtAddMsg 60810, 10, '60810 Invalid type', 'us_english'
execute rdt.rdtAddMsg 60811, 10, '60811 Invalid pallet ID', 'us_english'
execute rdt.rdtAddMsg 60812, 10, '60812 No open pallet', 'us_english'
execute rdt.rdtAddMsg 60813, 10, '60813 Differences found', 'us_english'
execute rdt.rdtAddMsg 60814, 10, '60814 Close pallet fail', 'us_english'
execute rdt.rdtAddMsg 60815, 10, '60815 Invalid case ID', 'us_english'
execute rdt.rdtAddMsg 60816, 10, '60816 No open case', 'us_english'
execute rdt.rdtAddMsg 60817, 10, '60817 Differences found', 'us_english'
execute rdt.rdtAddMsg 60818, 10, '60818 Get CSAudit fail', 'us_english'
execute rdt.rdtAddMsg 60819, 10, '60819 Get PickDetail fail', 'us_english'
execute rdt.rdtAddMsg 60820, 10, '60820 No PickDetail to offset', 'us_english'
execute rdt.rdtAddMsg 60821, 10, '60821 nspg_getkey fail', 'us_english'
execute rdt.rdtAddMsg 60822, 10, '60822 Retry again. PickDetail changed by other process', 'us_english'
execute rdt.rdtAddMsg 60823, 10, '60823 Update PickDetail.CaseID fail', 'us_english'
execute rdt.rdtAddMsg 60824, 10, '60824 Insert PickDetail fail', 'us_english'
execute rdt.rdtAddMsg 60825, 10, '60825 Close pallet fail', 'us_english'
execute rdt.rdtAddMsg 67051, 10, '67051 Get PickDetail fail', 'us_english'

execute rdt.rdtDropMsg 60809