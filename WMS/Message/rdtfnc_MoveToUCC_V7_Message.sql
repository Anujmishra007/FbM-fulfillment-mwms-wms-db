--rdtfnc_MoveToUCC_V7
execute rdt.rdtdropmsg 148351 , 148400	

execute rdt.rdtAddMsg 148351, 10, '148351TOLOC NEEDED  ', 'us_english', 639
execute rdt.rdtAddMsg 148352, 10, '148352INV TOLOC     ', 'us_english', 639
execute rdt.rdtAddMsg 148353, 10, '148353DIFF FACILITY ', 'us_english', 639
execute rdt.rdtAddMsg 148354, 10, '148354LOSEUCC TOLOC ', 'us_english', 639
execute rdt.rdtAddMsg 148355, 10, '148355FROMLOC NEEDED', 'us_english', 639
execute rdt.rdtAddMsg 148356, 10, '148356INV FROMLOC   ', 'us_english', 639
execute rdt.rdtAddMsg 148357, 10, '148357DIFF FACILITY ', 'us_english', 639
execute rdt.rdtAddMsg 148358, 10, '148358NOT LOSEUCC   ', 'us_english', 639
execute rdt.rdtAddMsg 148359, 10, '148359Same FromToLOC', 'us_english', 639
execute rdt.rdtAddMsg 148360, 10, '148360INV ID        ', 'us_english', 639
execute rdt.rdtAddMsg 148361, 10, '148361SKU NEEDED    ', 'us_english', 639
execute rdt.rdtAddMsg 148362, 10, '148362INV SKU       ', 'us_english', 639
execute rdt.rdtAddMsg 148364, 10, '148364MultiSKUBarcod', 'us_english', 639
execute rdt.rdtAddMsg 148365, 10, '148365Nothing ToMove', 'us_english', 639
execute rdt.rdtAddMsg 148366, 10, '148366NO QTY TO MOVE', 'us_english', 639
execute rdt.rdtAddMsg 148367, 10, '148367INV QTY       ', 'us_english', 639
execute rdt.rdtAddMsg 148368, 10, '148368INV QTY       ', 'us_english', 639
execute rdt.rdtAddMsg 148369, 10, '148369SKU NOT SAME  ', 'us_english', 639
execute rdt.rdtAddMsg 148370, 10, '148370QTYAVL NOTENUF', 'us_english', 639
execute rdt.rdtAddMsg 148371, 10, '148371NO QTY TO MOVE', 'us_english', 639
execute rdt.rdtAddMsg 148372, 10, '148372NO QTY TO MOVE', 'us_english', 639
execute rdt.rdtAddMsg 148373, 10, '148373TOUCC NEEDED  ', 'us_english', 639
execute rdt.rdtAddMsg 148374, 10, '148374INVALID FORMAT', 'us_english', 639
execute rdt.rdtAddMsg 148375, 10, '148375TOUCC EXISTS  ', 'us_english', 639
execute rdt.rdtAddMsg 148376, 10, '148376Invalid Format', 'us_english', 639

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148351 AND 148400