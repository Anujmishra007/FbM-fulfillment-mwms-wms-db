--rdtfnc_PalletConsolidate_BESE
--260751 - 260800
execute rdt.rdtdropmsg 260751 , 260800

execute rdt.rdtAddMsg 260751, 10, '260751^ToID NEEDED',         'us_english', 1878, 0, '260751: ToID is required'
execute rdt.rdtAddMsg 260752, 10, '260752^Invalid Format',      'us_english', 1878, 0, '260752: Invalid format'
execute rdt.rdtAddMsg 260753, 10, '260753^OPTION NEEDED',       'us_english', 1878, 0, '260753: Option is required'
execute rdt.rdtAddMsg 260754, 10, '260754^Invalid Option',      'us_english', 1878, 0, '260754: Invalid Option'
execute rdt.rdtAddMsg 260755, 10, '260755^FromID NEEDED',       'us_english', 1878, 0, '260755: FromID is required'
execute rdt.rdtAddMsg 260756, 10, '260756^FromIDNotExist',      'us_english', 1878, 0, '260756: FromID Not Exist'
execute rdt.rdtAddMsg 260757, 10, '260757^IDShipped',           'us_english', 1878, 0, '260757: FromID is shipped'
execute rdt.rdtAddMsg 260758, 10, '260758^BothIDSame',          'us_english', 1878, 0, '260758: Same as ToID'
execute rdt.rdtAddMsg 260759, 10, '260759^Invalid Format',      'us_english', 1878, 0, '260759: Invalid format'
execute rdt.rdtAddMsg 260760, 10, '260760^OPTION NEEDED',       'us_english', 1878, 0, '260760: Option is required'
execute rdt.rdtAddMsg 260761, 10, '260761^Invalid Option',      'us_english', 1878, 0, '260761: Invalid Option'

select * from rdt.RDTMsg (nolock) where message_id between 260751 and 260800
