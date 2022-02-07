


select * from rdt.rdtmsg (nolock) where message_id between '171801' and '171850'

-- rdtfnc_TM_Assist_ClusterPick
execute rdt.rdtDropMsg 171801, 171850

execute rdt.rdtAddMsg 171801, 10, '171801 Need PickZone ', 'us_english', 1855
execute rdt.rdtAddMsg 171802, 10, '171802PKZone No Task ', 'us_english', 1855
execute rdt.rdtAddMsg 171803, 10, '171803 Need CartID   ', 'us_english', 1855
execute rdt.rdtAddMsg 171804, 10, '171804Invalid CartID ', 'us_english', 1855
execute rdt.rdtAddMsg 171805, 10, '171805 Cart In Use   ', 'us_english', 1855
execute rdt.rdtAddMsg 171806, 10, '171806 Need Method   ', 'us_english', 1855
execute rdt.rdtAddMsg 171807, 10, '171807Invalid Method ', 'us_english', 1855
execute rdt.rdtAddMsg 171808, 10, '171808Invalid Method ', 'us_english', 1855
execute rdt.rdtAddMsg 171809, 10, '171809Lock Task Fail ', 'us_english', 1855
execute rdt.rdtAddMsg 171810, 10, '171810 Need Tote Id  ', 'us_english', 1855
execute rdt.rdtAddMsg 171811, 10, '171811 Tote Assigned ', 'us_english', 1855
execute rdt.rdtAddMsg 171812, 10, '171812 All Assigned  ', 'us_english', 1855
execute rdt.rdtAddMsg 171813, 10, '171813 Assign Fail   ', 'us_english', 1855
execute rdt.rdtAddMsg 171814, 10, '171814 Need Loc      ', 'us_english', 1855
execute rdt.rdtAddMsg 171815, 10, '171815 Loc Not Match ', 'us_english', 1855
execute rdt.rdtAddMsg 171816, 10, '171816 Need SKU      ', 'us_english', 1855
execute rdt.rdtAddMsg 171817, 10, '171817 Invalid SKU   ', 'us_english', 1855
execute rdt.rdtAddMsg 171818, 10, '171818MultiSKUBarcod ', 'us_english', 1855
execute rdt.rdtAddMsg 171819, 10, '171819 Wrong SKU     ', 'us_english', 1855
execute rdt.rdtAddMsg 171820, 10, '171820 Invalid QTY   ', 'us_english', 1855
execute rdt.rdtAddMsg 171821, 10, '171821 All QTY Short ', 'us_english', 1855
execute rdt.rdtAddMsg 171822, 10, '171822 Over Pick     ', 'us_english', 1855
execute rdt.rdtAddMsg 171823, 10, '171823 Need Tote Id  ', 'us_english', 1855
execute rdt.rdtAddMsg 171824, 10, '171824 ToteNotMatch  ', 'us_english', 1855
execute rdt.rdtAddMsg 171825, 10, '171825OptionRequired ', 'us_english', 1855
execute rdt.rdtAddMsg 171826, 10, '171826Invalid Option ', 'us_english', 1855
execute rdt.rdtAddMsg 171827, 10, '171827ToLOC Needed   ', 'us_english', 1855
execute rdt.rdtAddMsg 171828, 10, '171828ToLOC Diff     ', 'us_english', 1855
execute rdt.rdtAddMsg 171829, 10, '171829 Invalid LOC   ', 'us_english', 1855
execute rdt.rdtAddMsg 171830, 10, '171830Lock Task Fail ', 'us_english', 1855
execute rdt.rdtAddMsg 171831, 10, '171831 TaskQtyXTally ', 'us_english', 1855
execute rdt.rdtAddMsg 171832, 10, '171832 Tote In Use   ', 'us_english', 1855
execute rdt.rdtAddMsg 171833, 10, '171833 Tote In Use   ', 'us_english', 1855
execute rdt.rdtAddMsg 171834, 10, '171834 TaskLocXTally ', 'us_english', 1855
execute rdt.rdtAddMsg 171835, 10, '171835 Task Mismatch ', 'us_english', 1855
execute rdt.rdtAddMsg 171836, 10, '171836 Confirm Tote  ', 'us_english', 1855