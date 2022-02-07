--rdt_529ExtValidSP02
--execute rdt.rdtdropmsg 95951 - 96000
GO
DECLARE @nFunc INT

SET @nFunc = 529

execute rdt.rdtAddMsg 95951 ,10, '95951^DiffConsignee', 'us_english',@nFunc
execute rdt.rdtAddMsg 95952 ,10, '95952^DiffOrderKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 95953 ,10, '95953^ToteStatNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 95954 ,10, '95954^ToteStatNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 95955 ,10, '95955^CasePacked', 'us_english',@nFunc
execute rdt.rdtAddMsg 95956 ,10, '95956^CasePacked', 'us_english',@nFunc
execute rdt.rdtAddMsg 95957 ,10, '95957^DiffOrderKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 95958 ,10, '95958^ToteNotPacked', 'us_english',@nFunc
execute rdt.rdtAddMsg 95959 ,10, '95959^DropIDCaseIDNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 95960 ,10, '95960^DropIDNotInPack', 'us_english',@nFunc
execute rdt.rdtAddMsg 95961 ,10, '95961^DropIDNotInPack', 'us_english',@nFunc
execute rdt.rdtAddMsg 95962 ,10, '95962^OrderPackConfirm', 'us_english',@nFunc
execute rdt.rdtAddMsg 95963 ,10, '95963^OrderPackConfirm', 'us_english',@nFunc
