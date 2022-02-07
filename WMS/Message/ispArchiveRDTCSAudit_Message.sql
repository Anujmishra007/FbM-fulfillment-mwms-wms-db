/*
   60751 - 60775   ispArchiveRDTCSAudit
*/

-- ispArchiveRDTCSAudit (range 60751 - 60775)
execute rdt.rdtAddMsg 60751, 10, '60751 ArchiveKey does not exist (ispArchiveRDTCSAudit)', 'us_english'
execute rdt.rdtAddMsg 60752, 10, '60752 Target database does not exist (ispArchiveRDTCSAudit)', 'us_english'
execute rdt.rdtAddMsg 60753, 10, '60753 Insert @tTempRDTCSAUDIT fail (ispArchiveRDTCSAudit)', 'us_english'
execute rdt.rdtAddMsg 60754, 10, '60754 Delete GroupID that span across 2 days fail (ispArchiveRDTCSAudit)', 'us_english'
execute rdt.rdtAddMsg 60755, 10, '60755 Stamp ArchiveCop fail (ispArchiveRDTCSAudit)', 'us_english'
execute rdt.rdtAddMsg 60756, 10, '60756 Delete RDTCSAudit fail (ispArchiveRDTCSAudit)', 'us_english'

