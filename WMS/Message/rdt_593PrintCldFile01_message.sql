-- rdt_593PrintCldFile01_message
execute rdt.rdtDropMsg 222851 , 222900			

execute rdt.rdtAddMsg 222851, 10, '222851MissCodeSetup', 'us_english', 593, 0, '222851 Missing CODELKUP Setup'
execute rdt.rdtAddMsg 222852, 10, '222852InputRequired', 'us_english', 593, 0, '222852 Input Required'
execute rdt.rdtAddMsg 222853, 10, '222853InputRequired', 'us_english', 593, 0, '222853 * Field Must Have Value'
--222854 Validation SQL error (Dynamic error msg)
--222855 Validation Failure  (Dynamic error msg if cutomized msg defined)
execute rdt.rdtAddMsg 222855, 10, '222855ValidateFail', 'us_english', 593, 0, '222855 Validation Failure'
execute rdt.rdtAddMsg 222856, 10, '222856GetRptFail', 'us_english', 593, 0, '222856 Get Report Data Failure'
execute rdt.rdtAddMsg 222857, 10, '222857NotesEmpty', 'us_english', 593, 0, '222857 CODELKUP.Notes Is Empty'
execute rdt.rdtAddMsg 222858, 10, '222858RptNotSetup', 'us_english', 593, 0, '222858 Report Not Setup'
execute rdt.rdtAddMsg 222859, 10, '222859NotCldPrint', 'us_english', 593, 0, '222859 Report Is Not CLOUDPRINT Type'
execute rdt.rdtAddMsg 222860, 10, '222860MissWebSrvc', 'us_english', 593, 0, '222860 Miss GetFile Web Service Setup'
execute rdt.rdtAddMsg 222861, 10, '222861PrnterNotExist', 'us_english', 593, 0, '222861 Printer Not Exist'
execute rdt.rdtAddMsg 222862, 10, '222862NoCldPrntClntID', 'us_english', 593, 0, '222862 Must Set CloudPrintClientID'
execute rdt.rdtAddMsg 222863, 10, '222863NoFilePathParam', 'us_english', 593, 0, '222863 Miss FilePath (parm1_label)'
execute rdt.rdtAddMsg 222864, 10, '222864NoFileNameParam', 'us_english', 593, 0, '222864 Miss FileName (parm2_label)'
execute rdt.rdtAddMsg 222865, 10, '222865EmptyFilePath', 'us_english', 593, 0, '222865 FilePath Is Empty'
execute rdt.rdtAddMsg 222866, 10, '222866EmptyFileName', 'us_english', 593, 0, '222866 FileName Is Empty'
execute rdt.rdtAddMsg 222867, 10, '222867EncryptFileFail', 'us_english', 593, 0, '222867 FilePath Encryption Failure'
execute rdt.rdtAddMsg 222868, 10, '222868URLEncodeFail', 'us_english', 593, 0, '222868 URL Encoding Failure'
execute rdt.rdtAddMsg 222869, 10, '222869InsPrntJobFail', 'us_english', 593, 0, '222869 Insert Print Job Failure'
execute rdt.rdtAddMsg 222870, 10, '222870SubCldPntFail', 'us_english', 593, 0, '222870 Submit Cloud Print Task Failure'
execute rdt.rdtAddMsg 222871, 10, '222871RptNotSetup', 'us_english', 593, 0, '222871 Report Not Setup'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 222851 AND 222900
