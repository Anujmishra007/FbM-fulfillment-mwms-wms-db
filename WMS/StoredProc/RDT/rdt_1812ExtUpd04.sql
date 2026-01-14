SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
/************************************************************************/
/* Store procedure: [rdt_1812ExtUpd04]                                  */
/*                                                                      */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: JCB                                                         */
/*                                                                      */
/* Date        Author   Ver.     Purposes                               */
/* 2025-06-09  JCH507   1.0.0    FCR-3959 CREATED                       */
/* 2025-07-07  JCH507   1.0.1    FCR-3959 V1.6. Unhold loc in same bin  */
/*                                 if the whole pallet (FP) is picked   */
/* 2025-12-09  AGM046   2.0.0    Adding label printing to step 3        */
/* 2025-12-11  AGM046   2.0.1    Adding label printing to steps 99/6/4  */
/* 2026-01-05  PPA374   2.0.2    Adding RDT.c_String28 update at step 2 */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtUpd04]
   @nMobile         INT,          
   @nFunc           INT,          
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,          
   @nInputKey       INT,          
   @cTaskdetailKey  NVARCHAR( 10),
   @cDropID         NVARCHAR( 20),
   @nQTY            INT,          
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT OUTPUT,   
   @cErrMsg         NVARCHAR( 20) OUTPUT,
   @nAfterStep      INT      
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @nDebugFlag  INT = 0

   DECLARE  @cSQL        NVARCHAR(MAX),
            @cSQLParam   NVARCHAR(MAX)
   
   DECLARE  @nScn             INT,
            @nFromScn         INT,
            @nFromStep        INT,
            @cUserName        NVARCHAR(128),
            @cPickMethod      NVARCHAR(10),
            @cExtUpdPrintSP   NVARCHAR(20),
            @cStorerKey       NVARCHAR(15),
            @cToLocCate       NVARCHAR(10),
            @cOrderKey        NVARCHAR(10),
            @nToLocMaxPallet  INT,
            @nToLocIDCount    INT,
            --V1.0.2 start
            @cFromLoc         NVARCHAR(10),
            @cFromLocRoom     NVARCHAR(30),
            @nRowCount        INT,
            --V1.0.2 end
            @dDateTimeNow     DATETIME,
			@isKittingOrder      INT,
			@isKittingOrder_PP   INT,
			@isKittingOrder_FP   INT,
			@isStandardOrder     INT,
			--
			@cLabelPrinter    NVARCHAR(10),
			@cPaperPrinter    NVARCHAR(10),	
			@cFacility        NVARCHAR(5),
			@cLabelType       NVARCHAR(10),
			--
			@c_pickingType   NVARCHAR(5), 	
			@cID NVARCHAR(20),
			@ToLoc NVARCHAR(20)

   SELECT   @nScn = Scn,
            @nFromStep = V_FromStep,
            @nFromScn = V_FromSCN,
            @cStorerKey = StorerKey,
            @cUserName = UserName,
            @cPickMethod = V_String4
   FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812ExtUpd04'
   
   IF @nFunc = 1812 -- PickSKU
   BEGIN      
	  IF @nStep = 2
      BEGIN
         DECLARE @c_PickSlipNo NVARCHAR(10) = '',@b_success INT = 0

		 UPDATE RDT.RDTMOBREC
		 SET C_String28 = V_LOC
		 WHERE Mobile = @nMobile

		 UPDATE RDT.RDTMOBREC
         SET C_DateTime1 = GETDATE()
         WHERE Mobile = @nMobile

         SELECT @cOrderKey = OrderKey
         FROM dbo.TaskDetail WITH (NOLOCK)
         WHERE TaskDetailKey = @cTaskdetailKey

         SELECT @c_PickSlipNo = PickHeaderKey
         FROM PICKHEADER WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey

         IF ISNULL(@c_PickSlipNo,'' )= ''
         BEGIN
            EXECUTE nspg_GetKey 
                  @KeyName     = 'PICKSLIP'
                  , @fieldlength = 9
                  , @keystring   = @c_PickSlipNo  OUTPUT
                  , @b_success   = @b_success     OUTPUT
                  , @n_err       = @nErrNO        OUTPUT
                  , @c_errmsg    = @cErrMsg       OUTPUT
                  , @b_resultset = 0
                  , @n_batch     = 1
         
            SET @c_PickSlipNo = 'P' + @c_PickSlipNo

            INSERT INTO PICKHEADER 
               (  PickHeaderKey
               ,  Orderkey
               ,  Storerkey
               ,  ExternOrderkey
               ,  Priority
               ,  Type
               ,  Zone
               ,  Status
               ,  PickType
               ,  WAVEKEY
               )
            SELECT @c_PickSlipNo
               ,  Orderkey
               ,  Storerkey
               ,  Loadkey
               ,  Priority
               ,  Priority --TYPE
               ,  'DEFAULT' --ZONE
               ,  '0'
               ,  '0'
               ,  @c_PickSlipNo
            FROM ORDERS WITH (NOLOCK)
            WHERE Orderkey = @cOrderKey
         END

         IF NOT EXISTS (   SELECT 1
                           FROM PICKINGINFO WITH (NOLOCK)
                           WHERE PickSlipNo = @c_PickSlipNo
                        )
         BEGIN
            INSERT INTO PICKINGINFO 
               (  PickSlipNo
               ,  ScanInDate
               ,  ScanOutDate
               ,  PickerID
               --,  TrafficCop         -- Fixed for Order status update to '3' 
               )
            VALUES 
               (  @c_PickSlipNo
               ,  GETDATE()
               ,  NULL
               ,  SUSER_NAME()
               --,  NULL               -- Fixed for Order status update to '3'
               )
         END
      END	  
	  	  	  
	  --
	  IF @nStep = 3 --FROMID
	  BEGIN	
	     --
	     IF @nInputKey = 1
         BEGIN
		    --
			SET @isStandardOrder = 0 			
			-- Picking labels 
			SET @c_pickingType = ''	
			SET @cID = ''
			SET @ToLoc = ''
			-- Get if full pallet
			SELECT 
			   @c_pickingType = td.PickMethod, 		
			   @cID = td.FromID,
			   @ToLoc = td.toloc
	        FROM dbo.TASKDETAIL td WITH (NOLOCK)
	        WHERE td.taskdetailkey = @cTaskdetailKey
           -- Get If standard Order            	   			     		   
			  SELECT @isStandardOrder =
			  CASE 
				WHEN EXISTS (
				  SELECT 1
				  FROM taskdetail td WITH (NOLOCK)
				  JOIN orders o WITH (NOLOCK)
					ON td.OrderKey  = o.OrderKey
				   AND td.Storerkey = o.StorerKey
				  WHERE td.TaskDetailKey = @cTaskdetailKey
					AND o.Facility = 'EMG03'
					AND o.[Type] IN ('0','1')
				)
				THEN 1
				ELSE 0
			  END 
					--								
					IF @c_pickingType = 'FP' --AND @ToLoc like 'ESM%'	
					AND @isStandardOrder = 1
					BEGIN	
						--
						SET  @cLabelPrinter  = ''
						SET  @cPaperPrinter  = ''	
						SET  @cFacility      = ''
						SET  @cLabelType     = '' 
						--
						DECLARE @b_totalSkuInPallet INT = 0,
						        @tMonoMultiLbl AS VariableTable						                    			        												
						-- Full Pallet to Stage Outbound (Not Kitting)
						-- Get MonoSku or MultiSku pallet		   
						SELECT @b_totalSkuInPallet = COUNT(DISTINCT(lli.Sku)) 
						  FROM dbo.LOTxLOCxID lli WITH (NOLOCK)
						 WHERE lli.storerkey = 'JCB'
						   AND lli.qty > 0
						   --AND lli.loc LIKE 'ESM%'
						   AND lli.Id = @cID
						 GROUP BY lli.Id
						 
						 -- Get printers parameters
						 SELECT @cFacility = Facility,
								@cLabelPrinter = Printer, 
								@cPaperPrinter = Printer_Paper
						   FROM rdt.rdtMobRec WITH (NOLOCK)
						  WHERE Mobile = @nMobile 						
						 -- Common params (To check)
						 INSERT INTO @tMonoMultiLbl (Variable, Value) VALUES
							   ( '@cStorerKey',     @cStorerKey),
							   ( '@cFacility',      @cFacility),
							   ( '@cDropID',        @cID),
							   ( '@cTaskdetailKey', @cTaskdetailKey)				   																	 
						 --						 
						IF @b_totalSkuInPallet = 1				
							BEGIN
							   --PRINT 'MONO SKU'
							   SET @cLabelType = 'PickMonSku'				   				 				  
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
								  @tMonoMultiLbl, -- Report params
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit	
							END				 
						ELSE IF @b_totalSkuInPallet > 1
							BEGIN
							   --PRINT 'MULTI SKU'
							   --First Print Out				
							   SET @cLabelType = 'PkMltSkuHd'
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
								  @tMonoMultiLbl, -- Report params
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit
							   --Second Print Out
							   SET @cLabelType = 'PkMltSkuLt'				   
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
								  @tMonoMultiLbl, -- Report params
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit					  
							END							
							ELSE 
							BEGIN 													
								SET @nErrNo = 260003 -- 260003^SkuInPallet<0
								SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
								GOTO Quit
							END								
					END -- END If Full Pallet Picking
          END --INPUTKEY = 0
	  END -- END Step 3
	  
	  --
	  IF @nStep = 4 
	  BEGIN	      
	     --
		 IF @nInputKey = 1
         BEGIN		     
			 -- Initialize variables
			   SET @isStandardOrder = 0 						 
			   SET @c_pickingType = ''	
			   SET @cID = ''
			   SET @ToLoc = ''						  			 			 			
			  -- Get Info from taskdetail 
			SELECT @c_pickingType = td.PickMethod, 		
			       @cID = td.Caseid,
			       @ToLoc = td.toloc
	          FROM dbo.TASKDETAIL td WITH (NOLOCK)
	         WHERE td.taskdetailkey = @cTaskdetailKey
             -- Get If standard Order            	   			     		   
			 SELECT @isStandardOrder =
			  CASE 
				WHEN EXISTS (
				  SELECT 1
				  FROM taskdetail td WITH (NOLOCK)
				  JOIN orders o WITH (NOLOCK)
					ON td.OrderKey  = o.OrderKey
				   AND td.Storerkey = o.StorerKey
				  WHERE td.TaskDetailKey = @cTaskdetailKey
					AND o.Facility = 'EMG03'
					AND o.[Type] IN ('0','1')
					AND TaskType = 'FCP'
				)
				THEN 1
				ELSE 0	
			 END 			 
			  	 --		  
			     IF @c_pickingType = 'PP' AND @isStandardOrder = 1 AND @cID is not null AND @cID <>''
				 BEGIN	
					   DECLARE @b_totalSkuInCase INT = 0,
						       @tMonoCaseLbl AS VariableTable						
						-- Full Pallet to Stage Outbound (Not Kitting)
						-- Get MonoSku or MultiSku pallet		   
						SELECT @b_totalSkuInCase = COUNT(DISTINCT(lli.Sku)) 
						  FROM dbo.LOTxLOCxID lli WITH (NOLOCK)
						  JOIN LOTATTRIBUTE la WITH (NOLOCK)
						    ON la.Lot = lli.Lot
						 WHERE lli.storerkey = 'JCB'
						   AND lli.qty > 0						  
						   AND la.Lottable11 = @cID
						 GROUP BY lli.Id
											 
						-- Get printers parameters
						SELECT @cFacility = Facility,
							   @cLabelPrinter = Printer, 
							   @cPaperPrinter = Printer_Paper
						  FROM rdt.rdtMobRec WITH (NOLOCK)
						 WHERE Mobile = @nMobile 

						 -- Common params (To check)
						 INSERT INTO @tMonoCaseLbl (Variable, Value) VALUES
							   ( '@cStorerKey',     @cStorerKey),
							   ( '@cFacility',      @cFacility),
							   ( '@cDropID',        @cID),
							   ( '@cTaskdetailKey', @cTaskdetailKey)				   																	 
						    --												 
						    IF @b_totalSkuInCase = 1				
							BEGIN
							   --PRINT 'MONO SKU'
							   SET @cLabelType = 'PickMonSku'				   				 				  
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
								  @tMonoCaseLbl, -- Report params
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit	
							END													
						    ELSE IF @b_totalSkuInCase > 1
							BEGIN
							   --PRINT 'MULTI SKU'
							   --First Print Out				
							   SET @cLabelType = 'PkMltSkuHd'
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
								  @tMonoCaseLbl, 
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit
							   --Second Print Out
							   SET @cLabelType = 'PkMltSkuLt'				   
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
								  @tMonoCaseLbl, 
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit					  
							END							
							ELSE 
							BEGIN 
							   SET @nErrNo = 260004  --'260004^SkuInCase<0'
							   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
							  GOTO Quit
							END								  
			     END 
         END --INPUTKEY = 1			      			
	  END -- END STEP 4  

	  --	  
	  IF @nStep = 6 --ToLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ST6 - ToLoc, Enter'

            --Unlock task if PND_OUT reach the pallet capacity
             IF EXISTS (
                  SELECT 1 FROM dbo.LOC WITH (NOLOCK) 
                  WHERE LOC = @cToLOC 
                     AND LocationCategory = 'PND_OUT'
               )--check location capacity
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'PND location, check capacity'

               SELECT @nToLocIDCount = COUNT (DISTINCT ID) 
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               WHERE LOC = @cToLOC

               SELECT @nToLocMaxPallet = MaxPallet FROM dbo.LOC WITH (NOLOCK)
               WHERE LOC =@cToLOC

               IF @nToLocIDCount >= @nToLocMaxPallet
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Reach PND limition, unlock locked tasks'

                  IF EXISTS (
                     SELECT 1
                     FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE TaskType IN ('FCP', 'FCP1')
                        AND STATUS = '3'
                        AND UserKey = @cUserName
                        AND TaskDetailKey <> @cTaskdetailKey
                  )
                  BEGIN
                     BEGIN TRY
                        UPDATE dbo.TaskDetail WITH (ROWLOCK)
                        SET   
                           UserKey = '',
                           Status = '0'
                        WHERE TaskType IN ('FCP','FCP1')
                           AND UserKey = @cUserName
                           AND Status = '3'
                           AND TaskDetailKey <> @cTaskdetailKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 239751
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
                        GOTO Quit
                     END CATCH
                  END --Unlock Tasks
               END
            END

            --Call ExtprintSP
            SET @cExtUpdPrintSP = rdt.RDTGetConfig( @nFunc, 'ExtUpdPrintSP', @cStorerKey)
            IF @cExtUpdPrintSP = '0'
               SET @cExtUpdPrintSP = ''

            IF @cExtUpdPrintSP <> ''
            BEGIN
               IF EXISTS( SELECT 1 FROM sys.sysobjects WHERE name = @cExtUpdPrintSP AND type = 'P')
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Executing ExtUpdPrintSP', @cExtUpdPrintSP AS ExtUpdPrintSP
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtUpdPrintSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT '    
    
                  SET @cSQLParam =
                     '@nMobile         INT,           ' +
                     '@nFunc           INT,           ' +
                     '@cLangCode       NVARCHAR( 3),  ' +
                     '@nStep           INT,           ' +
                     '@nInputKey       INT,           ' +
                     '@cTaskdetailKey  NVARCHAR( 10), ' +
                     '@cDropID         NVARCHAR( 20), ' +
                     '@nQTY            INT,           ' +
                     '@cToLOC          NVARCHAR( 10), ' +
                     '@nErrNo          INT OUTPUT,    ' +
                     '@cErrMsg         NVARCHAR( 20) OUTPUT '    
    
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT 
    
                  IF @nErrNo <> 0    
                     GOTO Quit 
               END
            END

            --V1.0.1 start
            SELECT
               @cFromLoc = TD.FromLoc,
               @cFromLocRoom = LOC.LocationRoom
            FROM dbo.TaskDetail TD WITH (NOLOCK)
            JOIN dbo.Pallet PL WITH (NOLOCK)
               ON TD.StorerKey = PL.StorerKey
               AND TD.FromID = PL.PalletKey
            JOIN dbo.LOC WITH (NOLOCK)
               ON TD.FromLoc = LOC.LOC
            WHERE TD.TaskDetailKey = @cTaskdetailKey
               AND TD.PickMethod = 'FP' --Full pallet
               AND PL.PalletType LIKE 'D%'

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount <> 0
            BEGIN
               IF ISNULL(@cFromLocRoom,'') <> ''
               BEGIN
                  IF EXISTS (
                     SELECT 1 
                     FROM dbo.InventoryHold IH WITH (NOLOCK)
                     JOIN dbo.LOC WITH(NOLOCK)
                        ON IH.LOC = LOC.LOC
                     WHERE LOC.LocationRoom = @cFromLocRoom
                        AND IH.Hold = 1
                        AND IH.Status = 'DoublePal'
                  )
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'Unhold locations in same beam', @cFromLOC AS FromLoc, @cFromLocRoom AS LocBeam

                     BEGIN TRY
                        UPDATE IH WITH (ROWLOCK)
                        SET Hold = '0'
                        FROM dbo.InventoryHold IH
                        JOIN dbo.LOC WITH(NOLOCK)
                           ON IH.LOC = LOC.LOC
                        WHERE LOC.LocationRoom = @cFromLocRoom
                           AND IH.Hold = 1
                           AND IH.Status = 'DoublePal' 
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 239753
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
                        GOTO Quit
                     END CATCH
                  END -- has loc hold by DoublePal
               END --FromLocRoom <> ''
            END --rowcount <> 0
            --V1.0.1 end

            UPDATE RDT.RDTMOBREC
            SET C_DateTime1 = GETDATE()
            WHERE Mobile = @nMobile

            -- Print Label Head ('T4 Full pallet pick')		 
		    SET @isKittingOrder_FP = 0			 		     			 				     						  		  
		    --
		    SELECT @isKittingOrder_FP =
			   CASE 
			   WHEN EXISTS (
						  SELECT 1
							FROM taskdetail td WITH (NOLOCK)
							JOIN orders o
							  ON td.OrderKey  = o.OrderKey
							 AND td.Storerkey = o.StorerKey
						   WHERE td.TaskDetailKey = @cTaskdetailKey
							 AND o.Facility = 'EMG03'
							 AND o.[Type] IN ('6')
							 AND td.pickmethod = 'FP'
							 AND td.TaskType = 'FCP'
							 )							 
				THEN 1
				ELSE 0
		        END
		     --		   		   
		     IF @isKittingOrder_FP = 1 
			 BEGIN	
		             SET  @cLabelPrinter  = ''
				     SET  @cPaperPrinter  = ''	
			         SET  @cFacility      = ''
				     SET  @cLabelType     = ''
                     SET  @cID            = ''
                   -- Get ID (ToId or DropID)			
		          SELECT @cID = COALESCE(td.ToID, td.DropID)		  
		            FROM dbo.TASKDETAIL td WITH (NOLOCK)
		           WHERE td.taskdetailkey = @cTaskdetailKey				   				    
				 --Execute code to PRINT	
				 DECLARE @tKittingLblHead AS VariableTable                   						                   
				  -- Get printers parameters
				  SELECT @cFacility = Facility,
					     @cLabelPrinter = Printer, 
					     @cPaperPrinter = Printer_Paper							
				    FROM rdt.rdtMobRec WITH (NOLOCK)
			       WHERE Mobile = @nMobile 						                    					 
				  -- Common params (To check)
				  INSERT INTO @tKittingLblHead  (Variable, Value) VALUES
						                        ('@cStorerKey',     @cStorerKey),
						                        ('@cDropID',        @cID),
                                                ('@cTaskdetailKey', @cTaskdetailKey)                                         
						   -- PRINT KITTING LABEL HEADER						   			
						  SET @cLabelType = 'KitGenLbHd'
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
             END
		              
			 --  Print KITING Labes with SKUs List 
			 -- 'T4 Full pallet pick','CABS Tote Label', 'T4 Partial Pick Pallet','LANDPOWER Pallet Label'	            		 
		     SET @isKittingOrder = 0				  
		     SET @cID = ''
			 SET @cLabelPrinter  = ''
			 SET @cPaperPrinter  = ''			
		      -- Get ID (ToId or DropID)		 		
		  SELECT @cID = COALESCE(NULLIF(td.ToID, ''), NULLIF(td.DropID, ''))
            FROM dbo.TASKDETAIL td WITH (NOLOCK)
           WHERE td.taskdetailkey = @cTaskdetailKey
              -- Get printers parameters
		  SELECT @cFacility = Facility,
			     @cLabelPrinter = Printer, 
			     @cPaperPrinter = Printer_Paper
			     --@cID = V_String3 (Dropid)
		    FROM rdt.rdtMobRec WITH (NOLOCK)
		   WHERE Mobile = @nMobile 
		     --	 
		  SELECT @isKittingOrder =
		    CASE 
		    WHEN EXISTS (
				  SELECT 1
				  FROM taskdetail td WITH (NOLOCK)
				  JOIN orders o
					ON td.OrderKey  = o.OrderKey
				   AND td.Storerkey = o.StorerKey
				  WHERE td.TaskDetailKey = @cTaskdetailKey
					AND o.Facility = 'EMG03'
					AND o.[Type] IN ('2','6','8')
					AND td.TaskType IN ('FCP') -- to avoid from PDND
		   )
		   THEN 1
		   ELSE 0
		   END 			 
		      --		   		   
		      IF @isKittingOrder = 1 AND @cID <> '' AND @cID IS NOT NULL
			  BEGIN				      			       				    
					--Execute code to PRINT	
				    DECLARE @tKittingLblList AS VariableTable									                                																 
					-- Common params (To check)
					INSERT INTO @tKittingLblList  (Variable, Value) VALUES
						                          ('@cStorerKey', @cStorerKey),
						                          ('@cDropID',    @cID)						   				           
					-- PRINT KITTING LABEL HEADER						   				
					SET @cLabelType = 'KitGenLbLt'
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
               END		 
		 END --inputkey = 1
      END--St6
      
      IF @nStep = 7 -- ExitTM, Next Task Scn
      BEGIN
         IF @nInputKey = 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ST7 - MsgScn, ESC'

            IF EXISTS (
               SELECT 1
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskType IN ('FCP', 'FCP1')
                  AND STATUS = '3'
                  AND StorerKey = @cStorerKey
                  AND UserKey = @cUserName
            )
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Unlock locked tasks'

               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET   
                     UserKey = '',
                     Status = '0'
                  WHERE TaskType IN ('FCP','FCP1')
                     AND UserKey = @cUserName
                     AND StorerKey = @cStorerKey
                     AND Status = '3'
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 239752
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
                  GOTO Quit
               END CATCH
            END --Unlock Tasks
         END--inputkey = 0

      END --ST7
     	 
	 IF @nStep = 99
      BEGIN
         IF @nInputKey = 1
         BEGIN
            BEGIN
               UPDATE RDT.RDTMOBREC
                  SET C_String29 = I_Field01
               WHERE Mobile = @nMobile
            END

            IF (SELECT TOP 1 RemoveTaskFromUserQueue 
               FROM RDT.RDTMOBREC R WITH (NOLOCK) 
               INNER JOIN TaskManagerReason TMR WITH(NOLOCK)
                 ON R.I_Field01 = TMR.TaskManagerReasonKey
               WHERE Mobile = @nMobile) = 1
            BEGIN
               SET @dDateTimeNow = GETDATE()

               INSERT INTO dbo.TaskManagerSkipTasks
               SELECT DISTINCT
                  RM.UserName,
                  TD1.TaskDetailKey,
                  TD1.TaskType,
                  TD1.Caseid,
                  TD1.Lot,
                  TD1.FromLoc,
                  TD1.ToLoc,
                  TD1.FromId,
                  TD1.ToId,
                  @dDateTimeNow
               FROM TaskDetail TD1 WITH (NOLOCK)
                  INNER JOIN TaskDetail TD2 WITH (NOLOCK)
                     ON TD2.TaskDetailKey = @cTaskdetailKey
                     AND TD2.StorerKey = @cStorerKey
                     AND TD1.OrderKey = TD2.OrderKey
                     AND TD1.GroupKey = TD2.GroupKey
                     AND TD1.AreaKey = TD2.AreaKey
                  LEFT JOIN RDT.RDTMOBREC RM WITH (NOLOCK)
                     ON RM.StorerKey = @cStorerKey
                     AND RM.Mobile = @nMobile
               WHERE TD1.StorerKey = @cStorerKey

			   DELETE FROM TaskManagerSkipTasks
			   WHERE USERID = ''
            END
			 
			 DECLARE @ReasonCode varchar(20) 
			 -- 
			 SELECT @ReasonCode = R.C_String29
			   FROM RDT.RDTMOBREC R                  
              WHERE Mobile = @nMobile
             --
			 IF @ReasonCode NOT IN ('EXIT','SKIP') 
			 BEGIN				 
				 SET @isKittingOrder_PP = 0			 	
				 SET @cID = ''			 				     						   
				 -- Get if it is Kittinng Order ('CABS Tote Label','T4 Partial Pick Pallet','LANDPOWER Pallet Label')
				 -- PRINT HEADER LABEL			 
				 SELECT @isKittingOrder_PP =
				   CASE 
				   WHEN EXISTS (
							  SELECT 1
								FROM taskdetail td WITH (NOLOCK)
								JOIN orders o WITH (NOLOCK)
								  ON td.OrderKey  = o.OrderKey
								 AND td.Storerkey = o.StorerKey
							   WHERE td.TaskDetailKey = @cTaskdetailKey
								 AND o.Facility = 'EMG03'
								 AND o.[Type] IN ('2','6','8')
								 AND NOT (o.[Type] IN ('6') AND td.pickmethod = 'FP')
								 )
					THEN 1
					ELSE 0
				 END
				 --		   		   
				 IF @isKittingOrder_PP = 1  
				 BEGIN	
					   --
					       SET @cLabelPrinter  = ''
					       SET @cPaperPrinter  = ''	
					       SET @cFacility      = ''
					       SET @cLabelType     = ''
					       SET @cID            = ''				   				    
					   --Execute code to PRINT	
					   DECLARE @tKittingLblHeadPP AS VariableTable									                                
					   -- Get printers parameters
					    SELECT @cFacility = Facility,
							   @cLabelPrinter = Printer, 
							   @cPaperPrinter = Printer_Paper,
							   @cID = O_Field01
						  FROM rdt.rdtMobRec WITH (NOLOCK)
						 WHERE Mobile = @nMobile 											 			
					  -- Common params (To check)
					    INSERT INTO @tKittingLblHeadPP (Variable, Value) VALUES
													   ( '@cStorerKey',     @cStorerKey),
													   ( '@cDropID',        @cID),
													   ( '@cTaskdetailKey', @cTaskdetailKey)				   
							-- PRINT KITTING LABEL HEADER								
						   SET @cLabelType = 'KitGenLbHd'
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
							   @tKittingLblHeadPP, 
							  'rdt_1812ExtUpd04',
							   @nErrNo  OUTPUT,
							   @cErrMsg OUTPUT
							IF @nErrNo <> 0
						  GOTO Quit	
				 END -- END Kitting Orders
	             -------------------------			     
				 -- BULK LOCATIONS FLOW --
				 -------------------------
			     SET @isStandardOrder = 0 							
				 SET @c_pickingType = ''	
				 SET @cID = ''
				 SET @ToLoc = ''
				 -- 
				 SELECT @c_pickingType = td.PickMethod, 		
			            @cID = td.FromID,
			            @ToLoc = td.toloc
	               FROM dbo.TASKDETAIL td WITH (NOLOCK)
	              WHERE td.taskdetailkey = @cTaskdetailKey
			    -- Get If it is standard Order            	   			     		   
				SELECT @isStandardOrder =
				  CASE 
					WHEN EXISTS (
					  SELECT 1
					  FROM taskdetail td WITH (NOLOCK)
					  JOIN orders o WITH (NOLOCK)
						ON td.OrderKey  = o.OrderKey
					   AND td.Storerkey = o.StorerKey
					  WHERE td.TaskDetailKey = @cTaskdetailKey
						AND o.Facility = 'EMG03'
						AND o.[Type] IN ('0','1')
					)
					THEN 1
					ELSE 0
				END 
			    -- Get it Pallet come from Bulk Location
			    DECLARE @isBulkLocation INT = 0
				SELECT @isBulkLocation =
					CASE 
					WHEN EXISTS (			  
						Select 1
						  from TaskDetail td  WITH (NOLOCK)
						  join loc loc WITH (NOLOCK)
							on td.FromLoc = loc.Loc
						  join CODELKUP ck
							on ck.Long = loc.LocationCategory
						 where td.TaskDetailKey = @cTaskdetailKey
						   and ck.listname = 'JCBBKFRMLC'
						   and td.Storerkey = 'JCB'
						   and ck.Long <> 'PND_OUT'
					  )
					THEN 1
					ELSE 0
				 END  
				 --								
				 IF @c_pickingType = 'FP' AND @isBulkLocation = 1 AND @isStandardOrder = 1
				 BEGIN	
						--
						SET  @cLabelPrinter  = ''
						SET  @cPaperPrinter  = ''	
						SET  @cFacility      = ''
						SET  @cLabelType     = '' 
						--
						DECLARE @b_totalSkuInPallet_BLK INT = 0,
						        @tMonoMultiLbl_blk AS VariableTable						                    			        											
						-- Get MonoSku or MultiSku pallet		   
						SELECT @b_totalSkuInPallet_BLK = COUNT(DISTINCT(lli.Sku)) 
						  FROM dbo.LOTxLOCxID lli WITH (NOLOCK)
						 WHERE lli.storerkey = 'JCB'
						   AND lli.qty > 0
						   AND lli.Id = @cID
						 GROUP BY lli.Id								 										 							
						 -- Get printers parameters
						SELECT @cFacility = Facility,
							   @cLabelPrinter = Printer, 
							   @cPaperPrinter = Printer_Paper
						  FROM rdt.rdtMobRec WITH (NOLOCK)
						 WHERE Mobile = @nMobile 						
						 -- Common params (To check)
						 INSERT INTO @tMonoMultiLbl_blk (Variable, Value) VALUES
													   ( '@cStorerKey',     @cStorerKey),
													   ( '@cFacility',      @cFacility),
													   ( '@cDropID',        @cID),
													   ( '@cTaskdetailKey', @cTaskdetailKey)				   																	 
						    --						 
						    IF @b_totalSkuInPallet_BLK = 1				
							BEGIN
							   --PRINT 'MONO SKU'
							   SET @cLabelType = 'PickMonSku'				   				 				  
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
								  @tMonoMultiLbl_blk, -- Report params
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit	
							 END				 
						     ELSE IF @b_totalSkuInPallet_BLK > 1
							 BEGIN
							   --PRINT 'MULTI SKU'
							   --First Print Out				
							   SET @cLabelType = 'PkMltSkuHd'
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
								  @tMonoMultiLbl_blk, 
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit
							   --Second Print Out
							   SET @cLabelType = 'PkMltSkuLt'				   
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
								  @tMonoMultiLbl_blk, 
								  'rdt_1812ExtUpd04',
								  @nErrNo  OUTPUT,
								  @cErrMsg OUTPUT
							   IF @nErrNo <> 0
								  GOTO Quit					  
							END							
							ELSE 
							BEGIN 														
							   SET @nErrNo = 260005  --260005^SkuInBulk<0
							   SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
							  GOTO Quit
							END							
			     END -- END If Full Pallet Picking
			 END --IF @ReasonCode	
         END  --@nInputKey = 1  
      END --@nStep = 99
   END --1812
   --
   Quit:
END-- sp

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtUpd04] TO [NSQL]
GO
