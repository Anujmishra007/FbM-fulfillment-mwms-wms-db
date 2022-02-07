/*
   60826 - 60850   rdtfnc_PostPackAudit_Rescan
*/

-- rdtfnc_PostPackAudit_Rescan (range 60826 - 60850)
-- Pallet
execute rdt.rdtAddMsg 60826, 10, '60826 Invalid option', 'us_english'
execute rdt.rdtAddMsg 60827, 10, '60827 Fail to reset', 'us_english'
execute rdt.rdtAddMsg 60828, 10, '60828 No open pallet', 'us_english'

-- Case
execute rdt.rdtAddMsg 60830, 10, '60830 Invalid option', 'us_english'
execute rdt.rdtAddMsg 60831, 10, '60831 Fail to reset', 'us_english'
execute rdt.rdtAddMsg 60832, 10, '60832 No open case',  'us_english'

execute rdt.rdtDropMsg 60831
execute rdt.rdtDropMsg 60832
execute rdt.rdtDropMsg 60833
execute rdt.rdtDropMsg 60834

