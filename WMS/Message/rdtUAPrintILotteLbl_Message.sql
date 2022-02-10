--rdtUAPrintILotteLbl
execute rdt.rdtdropmsg 112751 , 112800

execute rdt.rdtAddMsg 112751, 10, '12751^Drop ID Req',      'us_english'
execute rdt.rdtAddMsg 112752, 10, '12752^Inv Drop ID',      'us_english'
execute rdt.rdtAddMsg 112753, 10, '12753^LabelPrnterReq',   'us_english'
execute rdt.rdtAddMsg 112754, 10, '12754^DWNOTSetup',       'us_english'
execute rdt.rdtAddMsg 112755, 10, '12755^TgetDB Not Set',   'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112751 AND 112800