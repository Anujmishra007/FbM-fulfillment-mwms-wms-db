--rdtfnc_TM_TotePicking
--execute rdt.rdtdropmsg 90001 - 90050
--execute rdt.rdtdropmsg 90051 - 90100

DECLARE @nFunc INT

SET @nFunc = 1809

execute rdt.rdtAddMsg '90016', 10, '90016^TOTENO req',      'us_english',@nFunc
execute rdt.rdtAddMsg '90017', 10, '90017^FromLoc Req',     'us_english',@nFunc
execute rdt.rdtAddMsg '90018', 10, '90018^Inv FromLoc',     'us_english',@nFunc
execute rdt.rdtAddMsg '90019', 10, '90019^SKU Req',         'us_english',@nFunc
execute rdt.rdtAddMsg '90020', 10, '90020^Inv SKU/UPC',     'us_english',@nFunc
execute rdt.rdtAddMsg '90021', 10, '90021^SKU Not Exists',  'us_english',@nFunc
execute rdt.rdtAddMsg '90022', 10, '90022^Option Req',      'us_english',@nFunc
execute rdt.rdtAddMsg '90023', 10, '90023^Invalid Option',  'us_english',@nFunc
execute rdt.rdtAddMsg '90024', 10, '90024^Reason Req',      'us_english',@nFunc
execute rdt.rdtAddMsg '90025', 10, '90025^Reason Req',      'us_english',@nFunc
execute rdt.rdtAddMsg '90026', 10, '90026^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90027', 10, '90027^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90028', 10, '90028^UpdWCSFailed',    'us_english',@nFunc
execute rdt.rdtAddMsg '90029', 10, '90029^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90030', 10, '90030^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90031', 10, '90031^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90032', 10, '90032^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90033', 10, '90033^InsDropIDFail',   'us_english',@nFunc
execute rdt.rdtAddMsg '90034', 10, '90034^InsDropIDFail',   'us_english',@nFunc
execute rdt.rdtAddMsg '90035', 10, '90035^InsTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90036', 10, '90036^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90037', 10, '90037^InsTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90038', 10, '90038^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90039', 10, '90039^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90040', 10, '90040^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90041', 10, '90041^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90042', 10, '90042^InsDropIDFail',   'us_english',@nFunc
execute rdt.rdtAddMsg '90043', 10, '90043^InsDropIDFail',   'us_english',@nFunc
execute rdt.rdtAddMsg '90044', 10, '90044^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90045', 10, '90045^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90046', 10, '90046^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90047', 10, '90047^NextTaskFncErr',  'us_english',@nFunc
execute rdt.rdtAddMsg '90048', 10, '90048^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90049', 10, '90049^UpdWCSFailed',    'us_english',@nFunc
execute rdt.rdtAddMsg '90050', 10, '90050^UpdWCSFailed',    'us_english',@nFunc
execute rdt.rdtAddMsg '90051', 10, '90051^UpdWCSFailed',    'us_english',@nFunc
execute rdt.rdtAddMsg '90052', 10, '90052^UpdWCSFailed',    'us_english',@nFunc
execute rdt.rdtAddMsg '90053', 10, '90053^InsDropIDFail',   'us_english',@nFunc
execute rdt.rdtAddMsg '90054', 10, '90054^InsDropIDFail',   'us_english',@nFunc
execute rdt.rdtAddMsg '90055', 10, '90055^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90056', 10, '90056^InvalidToteNo',   'us_english',@nFunc
execute rdt.rdtAddMsg '90057', 10, '90057^InvalidToteNo',   'us_english',@nFunc
execute rdt.rdtAddMsg '90058', 10, '90058^ToteNotMatch',    'us_english',@nFunc
execute rdt.rdtAddMsg '90059', 10, '90059^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90060', 10, '90060^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90061', 10, '90061^ToteCloseFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg '90062', 10, '90062^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90063', 10, '90063^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90064', 10, '90064^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90065', 10, '90065^UpdTaskFailed',   'us_english',@nFunc
execute rdt.rdtAddMsg '90066', 10, '90066^UpdTaskFailed',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90067', 10, '90067^QCNotInWCSROUTE', 'us_english',@nFunc     
execute rdt.rdtAddMsg '90068', 10, '90068^QCNotInWCSROUTE', 'us_english',@nFunc     
execute rdt.rdtAddMsg '90069', 10, '90069^UpdTaskFailed',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90070', 10, '90070^NextTaskFncErr',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90071', 10, '90071^NextTaskScnErr',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90072', 10, '90072^NextTaskFncErr',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90073', 10, '90073^NextTaskScnErr',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90074', 10, '90074^NextTaskFncErr',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90075', 10, '90075^NextTaskScnErr',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90076', 10, '90076^Tote In Use',     'us_english',@nFunc         
execute rdt.rdtAddMsg '90077', 10, '90077^WcsStatnNotSet',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90078', 10, '90078^WcsStatnNotSet',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90079', 10, '90079^OverPickXAllow',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90080', 10, '90080^UpdTaskFailed',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90081', 10, '90081^UpdTaskFailed',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90082', 10, '90082^UpdTaskFailed',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90083', 10, '90083^Tote Swapped',    'us_english',@nFunc        
execute rdt.rdtAddMsg '90084', 10, '90084^UpdateToteFail',  'us_english',@nFunc      
execute rdt.rdtAddMsg '90085', 10, '90085^InvalidToteNo',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90086', 10, '90086^InvalidToteNo',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90087', 10, '90087^InvalidToteNo',   'us_english',@nFunc       


                       
                       
                       
--SOS212191            
execute rdt.rdtAddMsg '90088', 10, '90088^Option Req',      'us_english',@nFunc
execute rdt.rdtAddMsg '90089', 10, '90089^Invalid Option',  'us_english',@nFunc
execute rdt.rdtAddMsg '90090', 10, '90090^INV TOTENO LEN',  'us_english',@nFunc
                       
--SOS222682            
execute rdt.rdtAddMsg '90091', 10, '90091^INV TOTE NO',     'us_english',@nFunc

execute rdt.rdtAddMsg '90092', 10, '90092^TOTE NOT SAME',     'us_english',@nFunc

execute rdt.rdtAddMsg '90093', 10, '90093^DelDIDDetFail',     'us_english',@nFunc
execute rdt.rdtAddMsg '90094', 10, '90094^DelDropIDFail',     'us_english',@nFunc
execute rdt.rdtAddMsg '90095', 10, '90095^UpdTaskFailed',     'us_english',@nFunc
execute rdt.rdtAddMsg '90096', 10, '90096^UpdTaskFailed',     'us_english',@nFunc

execute rdt.rdtAddMsg '90097', 10, '90097^InsDropIDFail',     'us_english',@nFunc
execute rdt.rdtAddMsg '90098', 10, '90098^UpdTaskFailed',     'us_english',@nFunc  

-- (ChewKP06) 
execute rdt.rdtAddMsg '90098', 10, '90098^InvalidSKU',   'us_english',@nFunc       
execute rdt.rdtAddMsg '90099', 10, '90099^MultiSKUBarCod',   'us_english',@nFunc                  

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 90001 AND 90050
SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 90051 AND 90100
                       
                       
                       
                       
                       
                       
                       