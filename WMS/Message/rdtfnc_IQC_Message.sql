--rdtfnc_IQC
execute rdt.rdtDropMsg 64051, 64100

execute rdt.rdtAddMsg 64051, 10, '64051^QC REF needed',  'us_english', 1730
execute rdt.rdtAddMsg 64052, 10, '64052^IQC finalized',  'us_english', 1730
execute rdt.rdtAddMsg 64053, 10, '64053^Need FROM LOC',  'us_english', 1730
execute rdt.rdtAddMsg 64054, 10, '64054^Invalid LOC',    'us_english', 1730
execute rdt.rdtAddMsg 64055, 10, '64055^Diff facility',  'us_english', 1730
execute rdt.rdtAddMsg 64056, 10, '64056^NO task in LOC', 'us_english', 1730
execute rdt.rdtAddMsg 64057, 10, '64057^ID not on IQC',  'us_english', 1730
execute rdt.rdtAddMsg 64058, 10, '64058^SKU needed ',    'us_english', 1730
execute rdt.rdtAddMsg 64059, 10, '64059^Invalid SKU',    'us_english', 1730
execute rdt.rdtAddMsg 64060, 10, '64060^MultiSKUBarcod', 'us_english', 1730
execute rdt.rdtAddMsg 64061, 10, '64061^SKU not on IQC', 'us_english', 1730
execute rdt.rdtAddMsg 64062, 10, '64062^Invalid QTY',    'us_english', 1730
execute rdt.rdtAddMsg 64063, 10, '64063^Invalid QTY',    'us_english', 1730
execute rdt.rdtAddMsg 64064, 10, '64064^QTY too much ',  'us_english', 1730
execute rdt.rdtAddMsg 64065, 10, '64065^Bad IQCKey ',    'us_english', 1730
execute rdt.rdtAddMsg 64066, 10, '64066^Reason needed',  'us_english', 1730
execute rdt.rdtAddMsg 64067, 10, '64067^Invalid reason', 'us_english', 1730
execute rdt.rdtAddMsg 64068, 10, '64068^Option needed',  'us_english', 1730
execute rdt.rdtAddMsg 64069, 10, '64069^Invalid Option', 'us_english', 1730
execute rdt.rdtAddMsg 64070, 10, '64070^To LOC needed',  'us_english', 1730
execute rdt.rdtAddMsg 64071, 10, '64071^Invalid LOC',    'us_english', 1730
execute rdt.rdtAddMsg 64072, 10, '64072^Diff facility',  'us_english', 1730
execute rdt.rdtAddMsg 64073, 10, '64073^Option needed',  'us_english', 1730
execute rdt.rdtAddMsg 64074, 10, '64074^Invalid Option', 'us_english', 1730
execute rdt.rdtAddMsg 64075, 10, '64075^Upd QCDtl Fail', 'us_english', 1730
execute rdt.rdtAddMsg 64076, 10, '64076^Upd QCDtl Fail', 'us_english', 1730
execute rdt.rdtAddMsg 64077, 10, '64077^Upd QCDtl Fail', 'us_english', 1730
execute rdt.rdtAddMsg 64078, 10, '64078^Upd QCDtl Fail', 'us_english', 1730
execute rdt.rdtAddMsg 64079, 10, '64079^Upd QCDtl Fail', 'us_english', 1730

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 64051 AND 64100