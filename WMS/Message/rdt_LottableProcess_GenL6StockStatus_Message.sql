-- rdt_LottableProcess_GenL6StockStatus
execute rdt.rdtDropMsg 56751, 56800

execute rdt.rdtAddMsg 56751, 10, '56751 NeedProdStatus',   'us_english'
execute rdt.rdtAddMsg 56752, 10, '56752 Bad ProdStatus',   'us_english'
