-- rdtfnc_PrePalletizeSort
exec rdt.rdtDropMsg 147701 , 147750

execute rdt.rdtAddMsg 147701, 10, '47701^ASN Required',     'us_english', 1841
execute rdt.rdtAddMsg 147702, 10, '47702^LANE Required',    'us_english', 1841
execute rdt.rdtAddMsg 147703, 10, '47703^ASN Not Exists',   'us_english', 1841
execute rdt.rdtAddMsg 147704, 10, '47704^Diff Facility',    'us_english', 1841
execute rdt.rdtAddMsg 147705, 10, '47705^Diff Storer',      'us_english', 1841
execute rdt.rdtAddMsg 147706, 10, '47706^ASN Closed',       'us_english', 1841
execute rdt.rdtAddMsg 147707, 10, '47707^Invalid Lane',     'us_english', 1841
execute rdt.rdtAddMsg 147708, 10, '47708^Diff Facility',    'us_english', 1841
execute rdt.rdtAddMsg 147709, 10, '47709^UCC Required',     'us_english', 1841
execute rdt.rdtAddMsg 147710, 10, '47710^UCC Not Exists',   'us_english', 1841
execute rdt.rdtAddMsg 147711, 10, '47711^UCC Received',     'us_english', 1841
execute rdt.rdtAddMsg 147712, 10, '47712^TOID Received',    'us_english', 1841
execute rdt.rdtAddMsg 147713, 10, '47713^Invalid Format',   'us_english', 1841
execute rdt.rdtAddMsg 147714, 10, '47714^PltID NotMatch',   'us_english', 1841
execute rdt.rdtAddMsg 147715, 10, '47715^TOID Required',    'us_english', 1841
execute rdt.rdtAddMsg 147716, 10, '47716^TOID Not Exist',   'us_english', 1841
execute rdt.rdtAddMsg 147717, 10, '47717^Option Require',   'us_english', 1841
execute rdt.rdtAddMsg 147718, 10, '47718^Invalid option',   'us_english', 1841
execute rdt.rdtAddMsg 147719, 10, '47719^SKU required',     'us_english', 1841
execute rdt.rdtAddMsg 147720, 10, '47720^Invalid SKU',      'us_english', 1841
execute rdt.rdtAddMsg 147721, 10, '47721^MultiSKUBarcod',   'us_english', 1841
execute rdt.rdtAddMsg 147722, 10, '47722^SKU Not in ASN',   'us_english', 1841
execute rdt.rdtAddMsg 147723, 10, '47723^Different SKU',    'us_english', 1841
execute rdt.rdtAddMsg 147724, 10, '47724^QTY required',     'us_english', 1841
execute rdt.rdtAddMsg 147725, 10, '47725^Invalid Qty',      'us_english', 1841
execute rdt.rdtAddMsg 147726, 10, '47726^CaseCnt Diff',     'us_english', 1841
execute rdt.rdtAddMsg 147727, 10, '47727^INS UCC fail',     'us_english', 1841
execute rdt.rdtAddMsg 147728, 10, '47728^Option Require',   'us_english', 1841
execute rdt.rdtAddMsg 147729, 10, '47729^Invalid option',   'us_english', 1841
execute rdt.rdtAddMsg 147730, 10, '47730^Option Require',   'us_english', 1841
execute rdt.rdtAddMsg 147731, 10, '47731^Invalid option',   'us_english', 1841
execute rdt.rdtAddMsg 147732, 10, '47732^Lane NotIn ASN',   'us_english', 1841
execute rdt.rdtAddMsg 147733, 10, '47733^To ID In Used',    'us_english', 1841
execute rdt.rdtAddMsg 147734, 10, '47733^ID Diff Lane',     'us_english', 1841


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 147701 AND 147750

