-- rdtfnc_TM_Cluster_Pick
rdt.rdtDropMsg 148901 , 148950	

execute rdt.rdtAddMsg 148901, 10, '148901 CartId req   ',   'us_english', 640
execute rdt.rdtAddMsg 148902, 10, '148902CartIdNotMatch',   'us_english', 640
execute rdt.rdtAddMsg 148903, 10, '148903 Need Loc     ',   'us_english', 640
execute rdt.rdtAddMsg 148904, 10, '148904 Loc Not Match',   'us_english', 640
execute rdt.rdtAddMsg 148905, 10, '148905 Need Case Id ',   'us_english', 640
execute rdt.rdtAddMsg 148906, 10, '148906CaseIdNotMatch',   'us_english', 640
execute rdt.rdtAddMsg 148907, 10, '148907 Need SKU     ',   'us_english', 640
execute rdt.rdtAddMsg 148908, 10, '148908 Invalid SKU  ',   'us_english', 640
execute rdt.rdtAddMsg 148909, 10, '148909MultiSKUBarcod',   'us_english', 640
execute rdt.rdtAddMsg 148910, 10, '148910 SKU Not Match',   'us_english', 640
execute rdt.rdtAddMsg 148911, 10, '148911 Invalid QTY',     'us_english', 640
execute rdt.rdtAddMsg 148912, 10, '148912 AllShortWithQTY', 'us_english', 640
execute rdt.rdtAddMsg 148913, 10, '148913 Over Pick    ',   'us_english', 640
execute rdt.rdtAddMsg 148914, 10, '148914 Option req   ',   'us_english', 640
execute rdt.rdtAddMsg 148915, 10, '148915Invalid Option',   'us_english', 640
execute rdt.rdtAddMsg 148916, 10, '148916CaseID req    ',   'us_english', 640
execute rdt.rdtAddMsg 148917, 10, '148917CaseIDNotMatch',   'us_english', 640
execute rdt.rdtAddMsg 148918, 10, '148918 ToLOC needed ',   'us_english', 640
execute rdt.rdtAddMsg 148919, 10, '148919 ToLOC Diff   ',   'us_english', 640
execute rdt.rdtAddMsg 148920, 10, '148920 Invalid LOC  ',   'us_english', 640
execute rdt.rdtAddMsg 148921, 10, '148921 Reason needed',   'us_english', 640
execute rdt.rdtAddMsg 148922, 10, '148922NextTaskScnErr',   'us_english', 640
execute rdt.rdtAddMsg 148923, 10, '148923Invalid Reason',   'us_english', 640
execute rdt.rdtAddMsg 148924, 10, '148924InsSkipTskFail',   'us_english', 640
execute rdt.rdtAddMsg 148925, 10, '148925UpdTaskdetFail',   'us_english', 640
execute rdt.rdtAddMsg 148926, 10, '148926UpdTaskdetFail',   'us_english', 640


--WMS-17429
execute rdt.rdtAddMsg 148927, 10, '148927 Need Case Id ',   'us_english', 640
execute rdt.rdtAddMsg 148928, 10, '148928CaseIdNotMatch',   'us_english', 640

--WMS-17689
execute rdt.rdtAddMsg 148929, 10, '148929Need NewCaseId',   'us_english', 640

--WMS-22212
execute rdt.rdtAddMsg 148930, 10, '148930Assign Cart Id',   'us_english', 640
execute rdt.rdtAddMsg 148931, 10, '148931Invalid CartId',   'us_english', 640
execute rdt.rdtAddMsg 148932, 10, '148932Assign Cart Er',   'us_english', 640
execute rdt.rdtAddMsg 148934, 10, '148934UpdTaskdetFail',   'us_english', 640

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148901 AND 148950	