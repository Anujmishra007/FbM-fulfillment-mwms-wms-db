
--rdtfnc_PTL_PTS
-- 84051 , 84100

exec rdt.rdtDropMsg 84051 , 84100
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 816

execute rdt.rdtAddMsg 84051 ,10, '84051^UpdPackHFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84052 ,10, '84052^UpdPackHFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84053 ,10, '84053^InsPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84054 ,10, '84054^OverPacked', 'us_english',@nFunc
execute rdt.rdtAddMsg 84055 ,10, '84055^InsDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84056 ,10, '84056^RDTPASTDFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 84057 ,10, '84057^GetKeyFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 84058 ,10, '84058^InsTaskDetFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 84059 ,10, '84051^InsDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84060 ,10, '84060^InsDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84061 ,10, '84061^GenCtnLabelFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 84062 ,10, '84062^GenLblSPNotFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 84063 ,10, '84063^GenCtnLabelFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 84064 ,10, '84064^UpdDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84065 ,10, '84065^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84066 ,10, '84066^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84067 ,10, '84067^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84068 ,10, '84068^InsertPackInfoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84069 ,10, '84069^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84070 ,10, '84070^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84071 ,10, '84071^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84072 ,10, '84072^InsPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84073 ,10, '84073^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84074 ,10, '84074^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84075 ,10, '84075^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84076 ,10, '84076^OverPacked', 'us_english',@nFunc
execute rdt.rdtAddMsg 84077 ,10, '84077^UpdWCSRODetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84078 ,10, '84078^UpdWCSROtFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84078 ,10, '84078^UpdWCSROtFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84079 ,10, '84079^NoOpenCarton', 'us_english',@nFunc

-- (ChewKP08) 
execute rdt.rdtAddMsg 84080 ,10, '84080^GetKeyFailed', 'us_english',@nFunc

