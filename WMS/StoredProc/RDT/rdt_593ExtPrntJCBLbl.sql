SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_593ExtPrntJCBLbl                                */
/* Copyright      : Maersk                                              */
/* Purpose: Re Print  JCB Picking Labels                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date           Rev  Author     Purposes                              */
/* 29-Dec-2025    1.0  AGM046     Created                               */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_593ExtPrntJCBLbl] (
   @nMobile    INT,
   @nFunc      INT,
   @nStep      INT,
   @cLangCode  NVARCHAR(3),
   @cStorerKey NVARCHAR(15),
   @cOption    NVARCHAR(1),
   @cParam1    NVARCHAR(20), --DropID
   @cParam2    NVARCHAR(20),
   @cParam3    NVARCHAR(20),
   @cParam4    NVARCHAR(20),
   @cParam5    NVARCHAR(20),
   @nErrNo     INT           OUTPUT,
   @cErrMsg    NVARCHAR(20) OUTPUT
)
AS
BEGIN 
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   --
   DECLARE @cPaperPrinter     NVARCHAR( 10),
           @cLabelPrinter     NVARCHAR( 10),
           @cUserName         NVARCHAR( 18),
           @cFacility         NVARCHAR( 5),                 
           @nInputKey         INT = 1, -- Temp Fix
		   @nTypeOrder        INT = 99,
		   @ntotalSkuInPallet INT = 0,
		   @cID               NVARCHAR(20),
		   @cTaskdetailKey    NVARCHAR(20),
		   @cLabelType        NVARCHAR(20),
           @tStandardLbl      AS VariableTable,
		   @tKittingLblHead   AS VariableTable,
		   @tKittingLblList   AS VariableTable	
   --		   
   DECLARE @tSSCCList VariableTable
   --
   SELECT @cLabelPrinter = Printer,
          @cPaperPrinter = Printer_Paper,
          @cFacility = Facility,
          @cStorerkey = StorerKey,
          @cUserName = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   --
   SET @cID = @cParam1
   -- Insert test
   /*
   INSERT INTO [dbo].[TraceInfo]
			   ([TraceName]
			   ,[TimeIn]
			   ,[TimeOut]
			   ,[TotalTime]
			   ,[Step1]
			   ,[Step2]
			   ,[Step3]
			   ,[Step4]
			   ,[Step5]
			   ,[Col1]
			   ,[Col2]
			   ,[Col3]
			   ,[Col4]
			   ,[Col5])
		 Select N'rdt_593ExtPrntJCBLbl'
			   ,NULL
			   ,NULL
			   ,NULL
			   ,@nStep
			   ,@nMobile
			   ,@nFunc
			   ,@cLabelPrinter
			   ,@cPaperPrinter
			   ,@cFacility
			   ,@cStorerkey
			   ,NULL
			   ,NULL
			   ,NULL
   */   
   --
   IF (@cID IS NOT NULL AND LTRIM(RTRIM(@cID)) <> '')
   BEGIN
   --	
   IF @nInputKey = 1
   BEGIN      	 	    
      -- GET Taskdetailkey		  
	  SELECT @cTaskdetailKey = MIN(td.TaskDetailKey) -- td.TaskDetailKey			           
	  FROM dbo.taskdetail td WITH (NOLOCK)	   
	  WHERE td.storerkey = 'JCB'
	     AND td.tasktype = 'FCP'	    
		 AND (td.DropID = @cID or td.ToID = @cID)		  			 
	
	  -- GET TYPE ORDER	   
	  SELECT @nTypeOrder = od.[Type]  
	  FROM dbo.orders od WITH (NOLOCK)	
	     INNER JOIN dbo.pickdetail pd WITH(NOLOCK)
		    ON od.storerkey = pd.storerkey
			AND od.orderkey = pd.orderkey
	  WHERE od.storerkey = 'JCB'			
	     AND (pd.dropID = @cID OR pd.ID = @cID)
	  GROUP BY od.[Type]
		  
	  --IF IT IS STANDARD ORDER	
      IF (@nTypeOrder = 0)
	  BEGIN
	     -- GET TOTAL SKU INTO ID					
		 SELECT @ntotalSkuInPallet = COUNT(DISTINCT(lli.Sku)) 
		 FROM dbo.LOTxLOCxID lli WITH (NOLOCK)
		 WHERE lli.storerkey = 'JCB'
	        AND lli.qty > 0						   
			AND lli.Id = @cID
		 GROUP BY lli.Id
					
         -- Load parameters			   
	     INSERT INTO @tStandardLbl (Variable, Value) 
	     VALUES
	        ( '@cStorerKey',     @cStorerKey),
		    ( '@cFacility',      @cFacility),
		    ( '@cDropID',        @cID),
		    ( '@cTaskdetailKey', @cTaskdetailKey)															
					
         --SI MONOSKU
	     IF @ntotalSkuInPallet=1
	     BEGIN															  					   
	        --PRINT STANDARD 'MONO SKU'
			SET @cLabelType = 'RPikMonSku'			   				 				  
			
			EXEC RDT.rdt_Print 
			   @nMobile, 
			   @nFunc, 
			   @cLangCode, 
			   @nStep, 
			   @nInputKey, 
			   @cFacility, 
			   @cStorerKey, 
			   @cLabelPrinter, 
			   @cPaperPrinter,
			   @cLabelType,
			   @tStandardLbl, 
			   'rdt_1812ExtUpd04',
			   @nErrNo  OUTPUT,
			   @cErrMsg OUTPUT
			
			IF @nErrNo <> 0
			   GOTO Quit		   
			--		   		   
		 END
					
		 --SI ES MULTI
		 ELSE IF @ntotalSkuInPallet > 1
		 BEGIN																				         
		    --First Print Out				
		    SET @cLabelType = 'RPkMltSkuH'  
			
		    EXEC RDT.rdt_Print 
		       @nMobile, 
			   @nFunc, 
			   @cLangCode, 
			   @nStep, 
			   @nInputKey, 
			   @cFacility, 
			   @cStorerKey, 
			   @cLabelPrinter, 
			   @cPaperPrinter,
			   @cLabelType,
			   @tStandardLbl, 
			   'rdt_1812ExtUpd04',
			   @nErrNo  OUTPUT,
			   @cErrMsg OUTPUT
			
		    IF @nErrNo <> 0
		       GOTO Quit
			
            --Second Print Out
			SET @cLabelType = 'RPkMltSkuL'				   
			
			EXEC RDT.rdt_Print 
			   @nMobile, 
			   @nFunc, 
			   @cLangCode, 
			   @nStep, 
			   @nInputKey, 
			   @cFacility, 
			   @cStorerKey, 
			   @cLabelPrinter, 
			   @cPaperPrinter,
			   @cLabelType,
			   @tStandardLbl, 
			   'rdt_1812ExtUpd04',
			   @nErrNo  OUTPUT,
			   @cErrMsg OUTPUT
			
			IF @nErrNo <> 0
			   GOTO Quit									
		 END
		 ELSE
		 BEGIN					           						  
		    SET @nErrNo = 260001 -- 260001^SkuInPallet<0
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
		    GOTO Quit							    
		 END			 			 
	  END --(@nTypeOrder = 0)        		 
		 
	  --Si TIPO (2,6,8)
	  ELSE IF (@nTypeOrder IN (2,6,8))
	  BEGIN													
	     -- PRINT kiting order label HEADER					   
		 INSERT INTO @tKittingLblHead  (Variable, Value) 
		 VALUES
		    ( '@cStorerKey', @cStorerKey),
			( '@cDropID', @cID),
			( '@cTaskdetailKey', @cTaskdetailKey)								   
		 -- 				
		 SET @cLabelType = 'RPKitGLbHd' 	

		 EXEC RDT.rdt_Print 
		    @nMobile, 
			@nFunc, 
			@cLangCode, 
			@nStep, 
			@nInputKey, 
			@cFacility, 
			@cStorerKey, 
			@cLabelPrinter, 
			@cPaperPrinter,
			@cLabelType,
			@tKittingLblHead, 
			'rdt_1812ExtUpd04',
			@nErrNo  OUTPUT,
			@cErrMsg OUTPUT
		 
		 IF @nErrNo <> 0
		    GOTO Quit								
					 
		 -- PRINT Kitting Label List
 		 INSERT INTO @tKittingLblList  (Variable, Value) 
		 VALUES
		    ( '@cStorerKey',     @cStorerKey),
			( '@cDropID',        @cID)						   				           
		 
		 -- 						   				
		 SET @cLabelType = 'RKitGenLbL'
		
		 EXEC RDT.rdt_Print 
		    @nMobile, 
			@nFunc, 
			@cLangCode, 
			@nStep, 
			@nInputKey, 
			@cFacility, 
			@cStorerKey, 
			@cLabelPrinter, 
			@cPaperPrinter,
			@cLabelType,
			@tKittingLblList, 
			'rdt_1812ExtUpd04',
			@nErrNo  OUTPUT,
			@cErrMsg OUTPUT
			
		 IF @nErrNo <> 0
		    GOTO Quit					 					 
	  END --(@nTypeOrder IN (2,6,8))	 
	  ELSE
	  BEGIN 
	     SET @nErrNo = 260002 -- 260002^TypeOrderUNK
		 SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
	     GOTO Quit				
	  END	 
  END --@nInputKey = 1
  END --empty @ID	
Quit:
END
GO

GRANT EXECUTE ON rdt_593ExtPrntJCBLbl TO NSQL
GO
