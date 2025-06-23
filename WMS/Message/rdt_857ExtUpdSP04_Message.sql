exec rdt.rdtDropMsg 218701,218800

exec rdt.rdtAddMsg 218701,10,'218701^ContainerExist','us_english',857
exec rdt.rdtAddMsg 218702,10,'218702^No Container','us_english',857
exec rdt.rdtAddMsg 218703,10,'218703^Need Weight','us_english',857
exec rdt.rdtAddMsg 218704,10,'218704^No Mbol','us_english',857
exec rdt.rdtAddMsg 218705,10,'218705^InsContainerFail','us_english',857
exec rdt.rdtAddMsg 218706,10,'218706^MBOLNotFound','us_english',857
exec rdt.rdtAddMsg 218707,10,'218707^NeedEmptyPLWgt','us_english',857
exec rdt.rdtAddMsg 218708,10,'218708^UpdMbolDetailFail','us_english',857
exec rdt.rdtAddMsg 218709,10,'218709^Failed To Del','us_english',857

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 218701 AND 218800