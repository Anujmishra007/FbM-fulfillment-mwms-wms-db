SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_521ExtPA99ONBR                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Customized PA logic for Onbr                                */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 04-Sept-2024 1.0  ELB012   Project - RITM8172881 Copy rdt_521ExtPA19 */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_521ExtPA99ONBR] (
   @nMobile          INT, 
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @cUserName        NVARCHAR( 18),
   @cStorerKey       NVARCHAR( 15),
   @cFacility        NVARCHAR( 5), 
   @cLOC             NVARCHAR( 10),
   @cID              NVARCHAR( 18),
   @cLOT             NVARCHAR( 10),
   @cUCCNo           NVARCHAR( 100),
   @cSKU             NVARCHAR( 20),
   @nQty             INT,          
   @cSuggestedLOC    NVARCHAR( 10)         OUTPUT,  
   @cPickAndDropLoc  NVARCHAR( 10)  null   OUTPUT,  
   @nPABookingKey    INT                   OUTPUT,  
   @nErrNo           INT                   OUTPUT, 
   @cErrMsg          NVARCHAR( 20) =''     OUTPUT  
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @nSkuCube           FLOAT,
			@cFromLocCfg        NVARCHAR(10),
			@nFullPack          INT,
			@cFinalLocPAZoneS   NVARCHAR(15),
			@nUCCSkuCnt         INT,
			@nPLTSkuCnt         INT,
			@nQtdUCC            INT,  
			@nQtdLOC      	    INT,
			@nQtdUCCBP    	    INT,
			@nMaxCarton   	    INT,
			@nAvlCartonCtn	    INT,
			@cAllowToFinalLoc   BIT,
			@cLocBuffer         NVARCHAR(15),
			@nFinalLocPAZoneCnt INT,
			@nSKUCnt           	INT,
			@cFinalLocPAZone   	NVARCHAR(15),
			@cPALocStrategy     NVARCHAR(15),
			@cPAzoneRack        NVARCHAR(15),
            @cPAStrategyKey     NVARCHAR(10),
			@cSkuPickFace       NVARCHAR(10),
			@nQtyInPickFace     INT,
			@nQtyLimitPickFace  INT,
			@cOriginZone        NVARCHAR(15),
			@cHostWHCode        NVARCHAR(15),
			@nCubicCapacity     FLOAT,
			@nActualCubeLoc		FLOAT,
			@nCubeRequested		FLOAT,
			@cLogicalLocation   NVARCHAR(10),
			@cSuggestLocTemp    NVARCHAR(10),
			@cLottable02        NVARCHAR(10),
			@cInvStatus         NVARCHAR(10),
			@cPAzonePNDRack     NVARCHAR(10),
			@cPAStgQA           NVARCHAR(10),
			@cPAStgIN           NVARCHAR(10),
			@cBuffM1            NVARCHAR(10),
			@cBuffM2            NVARCHAR(10),
			@cBuffM3            NVARCHAR(10),
			@cBuffM4            NVARCHAR(10),
			@cBuffRk            NVARCHAR(10),
			@cPndM1             NVARCHAR(10),
			@cPndM2             NVARCHAR(10),
			@cPndM3             NVARCHAR(10),
			@cPndM4             NVARCHAR(10),
			@cPndRk             NVARCHAR(10)
	

	SET @cSuggestedLOC = ''

-- Get putaway strategy  
	SELECT @cPAStrategyKey  = ISNULL(Short,''),
			@cPALocStrategy = ISNULL(Long,'') , --ONBRBUFFRK
			@cPAzoneRack    = ISNULL(UDF01,''), --ONBR_RACK
			@cPAzonePNDRack = ISNULL(UDF02,''), --ONBRPNDRK
			@cPAStgQA       = ISNULL(UDF03,''), --ONBRSTGQA
			@cPAStgIN       = ISNULL(UDF04,''), --ONBRSTGIN
			@cInvStatus     = ISNULL(UDF05,'')  --GOO
      FROM dbo.CodeLKUP WITH (NOLOCK)  
     WHERE ListName = 'RDTExtPA'  
       AND StorerKey = @cStorerKey  
       AND Code2 = @cFacility  
       AND Code = @nFunc
    IF @@ROWCOUNT = 0
	BEGIN
		SET @nErrNo = 253551 
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --253551^CONFIG NOT SET
		GOTO quit
	END

	IF (@cPAStrategyKey = '' 
	OR @cPALocStrategy = ''
	OR @cPAzoneRack = ''
	OR @cPAzonePNDRack = ''
	OR @cPAStgQA = ''
	OR @cPAStgIN = '')
	BEGIN
		SET @nErrNo = 253552 
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --253552^CONFIG NOT SET
		GOTO quit
	END

-- Get Buffers Loc 
    SELECT  @cBuffM1    = ISNULL(UDF01,''), --ONBR BUFFER M1
			@cBuffM2    = ISNULL(UDF02,''), --ONBR BUFFER M2
			@cBuffM3    = ISNULL(UDF03,''), --ONBR BUFFER M3
			@cBuffM4    = ISNULL(UDF04,''), --ONBR BUFFER M4
			@cBuffRk    = ISNULL(UDF05,'')  --ONBR BUFFER RK
      FROM dbo.CodeLKUP WITH (NOLOCK)  
     WHERE ListName = 'ONBRBFFPND'
       AND StorerKey = @cStorerKey  
       AND Code = 'BUFFER'
    IF @@ROWCOUNT = 0
	BEGIN
		SET @nErrNo = 253553 
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --253553^CONFIG NOT SET
		GOTO quit
	END

	IF (@cBuffM1 = '' 
	OR  @cBuffM2 = ''
	OR  @cBuffM3 = ''
	OR  @cBuffM4 = ''
	OR  @cBuffRk = '')
	BEGIN
		SET @nErrNo = 253554 
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --253554^CONFIG NOT SET
		GOTO quit
	END

-- Get Pnds Loc 
    SELECT  @cPndM1    = ISNULL(UDF01,''), --ONBR PND M1
			@cPndM2    = ISNULL(UDF02,''), --ONBR PND M2
			@cPndM3    = ISNULL(UDF03,''), --ONBR PND M3
			@cPndM4    = ISNULL(UDF04,''), --ONBR PND M4
			@cPndRk    = ISNULL(UDF05,'')  --ONBR PND RK
      FROM dbo.CodeLKUP WITH (NOLOCK)  
     WHERE ListName = 'ONBRBFFPND'
       AND StorerKey = @cStorerKey  
       AND Code = 'PND'
    IF @@ROWCOUNT = 0
	BEGIN
		SET @nErrNo = 253555 
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --253555^CONFIG NOT SET
		GOTO quit
	END

	IF (@cPndM1 = '' 
	OR  @cPndM2 = ''
	OR  @cPndM3 = ''
	OR  @cPndM4 = ''
	OR  @cPndRk = '')
	BEGIN
		SET @nErrNo = 253556 
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --253556^CONFIG NOT SET
		GOTO quit
	END
	-- End get configs



	--Validate if exists any SKU with cube = 0
	IF ISNULL(@cUCCNo,'') = ''
	BEGIN
		IF EXISTS(
		SELECT 1 
		  FROM DBO.SKU WITH (NOLOCK)
		 WHERE SKU.SKU IN( SELECT DISTINCT SKU 
						 FROM LOTXLOCXID WITH (NOLOCK)
						WHERE LOTXLOCXID.ID = @cID 
						  AND LOTXLOCXID.Sku = @cSKU -- 523 USING PALLET PA
						  AND LOTXLOCXID.StorerKey = @cStorerKey
						  AND LOTXLOCXID.Qty > 0)
		   AND SKU.STDCUBE = 0 -- CREATED AND NOT YET SETUP
		   AND SKU.StorerKey = @cStorerKey)
		BEGIN
			SET @nErrNo = 253557
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NeedCube'
			GOTO Quit
		END  
	END
	ELSE
	BEGIN
		IF EXISTS(
		SELECT 1 
		  FROM DBO.SKU WITH (NOLOCK)
		 WHERE SKU.SKU IN( SELECT DISTINCT SKU 
						 FROM DBO.UCC WITH (NOLOCK)
						WHERE UCCNo = @cUCCNo 
						  AND UCC.StorerKey = @cStorerKey)
		   AND SKU.STDCUBE = 0 
		   AND SKU.StorerKey = @cStorerKey)
		BEGIN
			SET @nErrNo = 253558
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NeedCube'
			GOTO Quit
		END  
	END

	--Validate if exists PickFace for all SKUs
	IF ISNULL(@cUCCNo,'') <> ''
	BEGIN
		IF EXISTS(
		SELECT 1
		  FROM dbo.UCC AS U WITH (NOLOCK)
		 WHERE UCCNo = @cUCCNo
		   AND U.QTY > 0
		   AND U.STATUS = '1'
		   AND NOT EXISTS (
			SELECT 1
			FROM dbo.SKUxLOC AS S WITH (NOLOCK)
			WHERE S.StorerKey = U.StorerKey
			  AND S.SKU = U.SKU
			  AND S.QtyLocationLimit > 0
			  AND S.LocationType = 'PICK')
			  )
		BEGIN
			SET @nErrNo = 253559
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NoPickFace'
			GOTO Quit
		END   
	END
	ELSE
	BEGIN
		IF EXISTS(
		SELECT 1
		  FROM dbo.LOTXLOCXID AS L WITH (NOLOCK)
		 WHERE L.ID = @cID
		   AND L.SKU = @cSKU
		   AND L.QTY > 0
		   AND L.StorerKey = @cStorerKey
		   AND NOT EXISTS (
			SELECT 1
			FROM dbo.SKUxLOC AS S WITH (NOLOCK)
			WHERE S.StorerKey = L.StorerKey
			  AND S.SKU = L.SKU
			  AND S.QtyLocationLimit > 0
			  AND S.LocationType = 'PICK')
			  )
		BEGIN
			SET @nErrNo = 253560
			SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'NoPickFace'
			GOTO Quit
		END 
	END


	-----------------------------------
	------- Customized Strategy -------
	-----------------------------------

	--Always when receive and PA from StageQA should go to Rack's PND

	IF @cLOC = @cPAStgQA
	BEGIN
		SET @cSuggestedLOC = @cPAzonePNDRack 
		GOTO Quit
	END

IF @nFunc = 521
BEGIN

	SELECT TOP 1 @cLottable02 = LOTATTRIBUTE.lottable02 --Same Inv Status as HostWHCode
		FROM dbo.LOTxLOCxID WITH (NOLOCK) 
		JOIN dbo.LOTATTRIBUTE WITH (NOLOCK) 
		  ON LOTATTRIBUTE.LOT = LOTxLOCxID.LOT
		 AND LOTATTRIBUTE.StorerKey = LOTxLOCxID.StorerKey
		 AND LOTATTRIBUTE.SKU = LOTxLOCxID.SKU
		LEFT JOIN dbo.UCC WITH (NOLOCK) 
	      ON LOTxLOCxID.LOT = UCC.LOT 
		 AND LOTxLOCxID.SKU = UCC.SKU
		 AND UCC.STATUS = '1'
		 AND LOTxLOCxID.ID = UCC.ID
		WHERE LOTxLOCxID.StorerKey = @cStorerKey
			AND LOTxLOCxID.ID = @cID
			AND LOTxLOCxID.Loc = @cLoc
			AND UCCNo = @cUCCNo
			AND LOTxLOCxID.Qty > 0

	IF @cLOC = @cPAStgIN AND @cLottable02 <> @cInvStatus
	BEGIN
		SET @nErrNo = 253561
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Wrong Loc', should receive in STGQA
		GOTO Quit
	END 

	ELSE

	BEGIN
	--First Step: StgIN and Inv_status = 'GOO'
	IF @cLOC = @cPAStgIN 
		BEGIN

		 -- Get UCC info
			SELECT @nUCCSkuCnt = COUNT(DISTINCT SKU)
			FROM dbo.UCC WITH (NOLOCK) 
			WHERE StorerKey = @cStorerKey
			AND ID = @cID
			AND Loc = @cLOC
			AND UCCNO = @cUCCNo
			AND Qty > 0

			--Get zones
			SELECT 
				@nFinalLocPAZoneCnt = COUNT(DISTINCT L.PutawayZone),
				@nSKUCnt            = COUNT(DISTINCT PF.SKU),
				@cFinalLocPAZone    = ISNULL(MIN(L.PutawayZone),''),
				@cSkuPickFace       = ISNULL(MIN(PF.LOC),''),
				@cHostWHCode        = ISNULL(MIN(L.HOSTWHCODE),'')
			FROM DBO.SKUxLOC AS PF WITH (NOLOCK)
			JOIN DBO.LOC AS L WITH (NOLOCK) ON L.LOC = PF.LOC AND L.Facility = @cFacility
			JOIN DBO.UCC WITH (NOLOCK) ON UCC.SKU = PF.SKU AND UCC.Storerkey = @cStorerKey AND UCC.UCCNo = @cUCCNo
			WHERE PF.QtyLocationLimit > 0
			  AND PF.LocationType = 'PICK'
			  AND PF.StorerKey = @cStorerKey
		
			IF @cFinalLocPAZone = ''--PickFace PA Zone
			BEGIN
				SET @cSuggestedLOC = ''
				SET @nErrNo = 253562
				SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InvalidZone'
				GOTO Quit
			END
			ELSE
			BEGIN
				IF @cFinalLocPAZone = 'ONBR_M1'
					SET @cLocBuffer = @cBuffM1
				ELSE IF @cFinalLocPAZone = 'ONBR_M2'
					SET @cLocBuffer = @cBuffM2
				ELSE IF @cFinalLocPAZone = 'ONBR_M3'
					SET @cLocBuffer = @cBuffM3
				ELSE IF @cFinalLocPAZone = 'ONBR_M4'
					SET @cLocBuffer = @cBuffM4
			END

		   BEGIN
		   WITH LOC_FILTERED AS (
			   SELECT COUNT(LOC) AS LOC, SUM(MaxCarton) AS MaxCarton
			   FROM dbo.LOC WITH (NOLOCK)
			   WHERE PutawayZone = @cPAzoneRack
			   AND loc.Status <> 'HOLD'
			   AND loc.LocationFlag <> 'HOLD'
		   ),
		   UCC_FILTERED AS (
			   SELECT COUNT(DISTINCT U.UCCNo) AS UCCNo
			   FROM dbo.UCC U WITH (NOLOCK)
			   INNER JOIN dbo.LOC L WITH (NOLOCK) ON U.Loc = L.LOC
			   WHERE U.STATUS = '1'
				 AND U.Qty > 0
				 AND U.StorerKey = @cStorerKey
				 AND L.PutawayZone = @cPAzoneRack
				 AND l.Status <> 'HOLD'
				 AND l.LocationFlag <> 'HOLD'
		   ),
		   UCC_FILTERED_BUFFPND AS (
			   SELECT COUNT(DISTINCT UU.UCCNo) AS UCCNoBP
			   FROM dbo.UCC UU WITH (NOLOCK)
			   INNER JOIN dbo.LOC LL WITH (NOLOCK) ON UU.Loc = LL.LOC
			   WHERE UU.STATUS = '1'
				 AND UU.Qty > 0
				 AND UU.StorerKey = @cStorerKey
				 --AND LL.PutawayZone = @cPAzoneRack
				 AND (LL.Status = 'HOLD'
				 AND LL.LocationFlag = 'HOLD')
				 AND LL.LOC IN (@cBuffRk, @cPndRk)
				 AND LL.LocationCategory = @cPAzoneRack
		   )
		   SELECT 
			   @nQtdUCC       = U.UCCNo,
			   @nQtdLOC       = L.LOC,
			   @nQtdUCCBP     = UU.UCCNoBP,
			   @nMaxCarton    = L.MaxCarton,
			   @nAvlCartonCtn = ISNULL(L.MaxCarton, 0) - ISNULL(U.UCCNo, 0) - ISNULL(UU.UCCNoBP, 0)
		   FROM LOC_FILTERED L
		   CROSS JOIN UCC_FILTERED U
		   CROSS JOIN UCC_FILTERED_BUFFPND UU
		   END

		   -- Get pack info to calculate if fit in PickFace
			SELECT 
				LLI.SKU,
				ISNULL(UCC.qty,0) AS QtySkuUCC,
				P.CaseCNT,
				ISNULL(FinalLoc.MaxCarton,0) * ISNULL(P.CaseCNT,0) as CapacityPickFace,
				PF.LOC as PickFace,
				SUM(ISNULL(LLIFL.QTY,0)) + SUM(ISNULL(LLIFL.PendingMoveIn,0)) - (SUM(ISNULL(LLIFL.QtyPicked,0)) + SUM(ISNULL(LLIFL.QtyAllocated,0))) AS QtyPickFace,
				(
					SELECT ISNULL(SUM(BPM.QTY) + SUM(BPM.PendingMoveIn) - (SUM(BPM.QtyPicked) + SUM(BPM.QtyAllocated)),0)
					FROM dbo.LOTxLOCxID AS BPM WITH (NOLOCK)
					JOIN dbo.LOC as LCM WITH (NOLOCK)
					  ON BPM.LOC = LCM.LOC 
					 AND (LCM.Status <> 'HOLD' 
					 AND LCM.LocationFlag <> 'HOLD')
					WHERE LCM.PutawayZone IN (
						  SELECT CODE FROM DBO.CODELKUP WITH (NOLOCK) 
						  WHERE LISTNAME = 'ONBRAZONES' AND SHORT = 1
					)
					AND BPM.SKU = LLI.SKU
				) AS QtyBufferPndMez
			INTO #TempSku
			FROM dbo.LOTxLOCxID AS LLI WITH (NOLOCK)
			LEFT JOIN DBO.SKU AS SKU WITH (NOLOCK) ON LLI.SKU = SKU.SKU AND LLI.StorerKey = SKU.StorerKey
			LEFT JOIN DBO.Pack AS P WITH (NOLOCK) ON SKU.PACKKey = P.PackKey
			LEFT JOIN DBO.SKUxLOC AS PF WITH (NOLOCK) 
				   ON PF.SKU = LLI.SKU 
				  AND PF.QtyLocationLimit > 0 
				  AND PF.StorerKey = LLI.StorerKey
			JOIN dbo.LOC WITH (NOLOCK) ON LLI.Loc = LOC.LOC
			LEFT JOIN dbo.LOTxLOCxID AS LLIFL WITH (NOLOCK) 
				   ON PF.SKU = LLIFL.SKU 
				  AND PF.StorerKey = LLIFL.StorerKey 
				  AND PF.Loc = LLIFL.Loc
				  AND LLIFL.Qty > 0
			LEFT JOIN dbo.LOC AS FinalLoc WITH (NOLOCK) ON PF.Loc = FinalLoc.Loc
			LEFT JOIN dbo.LOTATTRIBUTE AS LOT WITH (NOLOCK) ON LLI.LOT = LOT.LOT
			LEFT JOIN dbo.UCC WITH (NOLOCK)
				   ON UCC.SKU = LLI.SKU 
				  AND UCC.LOT = LLI.LOT
				  AND UCC.ID = LLI.Id
				  AND UCC.Storerkey = LLI.StorerKey
				  AND UCC.STATUS = '1'
			WHERE LLI.StorerKey = @cStorerKey
			  AND LLI.ID = @cID
			  AND LLI.Loc = @cLOC
			  AND LLI.Qty > 0
			  AND LOT.Lottable02 = @cInvStatus
			  AND UCC.UCCNo = @cUCCNo
			GROUP BY LLI.SKU, PF.LOC, P.CaseCNT, FinalLoc.MaxCarton, UCC.qty

			IF EXISTS (
				SELECT 1
				FROM #TempSku
				WHERE QtyPickFace + QtySkuUCC + QtyBufferPndMez > CapacityPickFace
			)
			BEGIN
				SET @cAllowToFinalLoc = 0 -- Not Allowed			
			END
			ELSE
			BEGIN
				SET @cAllowToFinalLoc = 1 -- Allowed
			END

			IF OBJECT_ID('tempdb..#TempSku','u') IS NOT NULL
			BEGIN
				DROP TABLE #TempSku;
			END
		
			-- Strategy
			-- UCC SingleSKU 
			-- 1. Should check if is there capacity to PA to PickFace 
			-- 2. Not allowed to 1. Should check if is there capacity to PA to Rack
			-- 3. Not allowed to 2. Should return to respective mezzanine and PA to DynPPick

			IF @nUCCSkuCnt = 1
			BEGIN
				SELECT @nFullPack = ISNULL(PACK.CASECNT,0)
				  FROM DBO.SKU WITH (NOLOCK) 
				  JOIN DBO.PACK WITH (NOLOCK) 
				    ON SKU.PACKKEY = PACK.PackKey
				 WHERE SKU.SKU = @cSKU
				   AND SKU.StorerKey = @cStorerKey

				IF @nFullPack <> @nQty -- Less than fullcase should go to Mezzanine
				BEGIN
					SET @cSuggestedLOC = @cLocBuffer --Buffer M1 ~ M4
					GOTO Quit
				END
				ELSE --Case is full
				BEGIN
					IF @cAllowToFinalLoc = 1
					BEGIN
						SET @cSuggestedLOC = @cLocBuffer --Buffer M1 ~ M4
						GOTO Quit
					END
					ELSE
					BEGIN
					IF @nAvlCartonCtn - 1 >= 0
						BEGIN
							SET @cSuggestedLOC = @cPALocStrategy --Buffer Rack
							GOTO Quit                                  
						END
					ELSE
						BEGIN
							SET @cSuggestedLOC = @cLocBuffer --Buffer M1 ~ M4
							GOTO Quit
						END
					END
				END
			END
	
			-- STEP 2: If its a MultiSKU in UCC should PA to first Mezzanine found
			IF @nFinalLocPAZoneCnt > 1 OR @nUCCSkuCnt > 1
			BEGIN
			   SET @cSuggestedLOC = @cLocBuffer --Buffer M1 ~ M4
			   GOTO Quit
			END
		END

		ELSE-- Third Step -> PND Rack

		BEGIN
			SELECT @cOriginZone = PutawayZone 
			  FROM dbo.LOC WITH (NOLOCK) 
			 WHERE LOC = @cLOC

			IF @cPAzoneRack = @cOriginZone
			-- Validate if ToLoc allow mix SKU
			BEGIN
				WITH Loc_Filtered_Rack AS (
				SELECT 
					UCC.LOC,
					COUNT(UCCNO) AS QtyUcc,
					LOC.LogicalLocation,
					LOC.MaxCarton,
					LOC.CommingleSku,
					COUNT(DISTINCT UCC.SKU) AS QtySKU,
					CASE 
						WHEN COUNT(DISTINCT UCC.SKU) = 1 THEN MIN(UCC.SKU) 
						ELSE '' 
					END AS SKU
				FROM dbo.UCC WITH (NOLOCK)
				JOIN dbo.LOC WITH (NOLOCK)
					ON LOC.LOC = UCC.LOC
				   AND LOC.FACILITY = @cFacility
				   AND LOC.PutawayZone = @cOriginZone
				   AND LOC.HOSTWHCODE = @cLottable02
				   AND LOC.LOC NOT IN (@cPAzonePNDRack, @cBuffRk)
				   AND LOC.Status <> 'HOLD' 
				   AND LOC.LOCATIONFLAG <> 'HOLD'
				WHERE STORERKEY = @cStorerKey
				  AND UCC.STATUS <= '3'
				GROUP BY 
					UCC.LOC,
					LOC.LogicalLocation,
					LOC.MaxCarton,
					LOC.CommingleSku
			)
			SELECT TOP 1
				   @cSuggestedLOC    = LOC,
				   @cLogicalLocation = LogicalLocation,
				   @cSku             = CASE 
											WHEN CommingleSku = 0 THEN SKU 
											ELSE @cSku 
									   END
			FROM Loc_Filtered_Rack
			WHERE
				-- Capacidade sempre obrigatória
				QtyUcc + 1 <= MaxCarton
			AND
			(
				-- Não multi-SKU
				(CommingleSku = 0 AND QtySKU = 1 AND SKU = @cSKU)

				OR

				-- Multi-SKU permitido
				(CommingleSku = 1)
			)
			ORDER BY LogicalLocation
			/*	WITH Loc_Filtered_Rack AS (
					SELECT UCC.LOC,
					 COUNT(UCCNO) AS QtyUcc,
					 LOC.LogicalLocation,
					 LOC.MaxCarton
					 FROM dbo.UCC WITH (NOLOCK)
					 JOIN DBO.LOC  WITH (NOLOCK) 
					   ON LOC.LOC = UCC.LOC
					  AND LOC.FACILITY = @cFacility
					  AND LOC.PutawayZone = @cOriginZone
					  AND LOC.HOSTWHCODE = @cLottable02
					  AND LOC.LOC NOT IN
					  (@cPAzonePNDRack, @cBuffRk)
					WHERE STORERKEY = @cStorerKey
					  AND UCC.STATUS = '1'
					GROUP BY UCC.LOC, LOC.LogicalLocation, LOC.MaxCarton
				)
					SELECT TOP 1 @cSuggestedLOC = ISNULL(LOC,'')
					FROM Loc_Filtered_Rack
					WHERE QtyUcc + 1 <= MaxCarton

					IF @cSuggestedLOC <> ''
						BEGIN
							GOTO QUIT
						END
					ELSE 
					BEGIN
					SELECT TOP 1 @cSuggestedLOC = LOC.LOC, @cLogicalLocation = LOC.LogicalLocation
					  FROM DBO.LOC WITH (NOLOCK)
					 WHERE LOC.FACILITY = @cFacility
					   AND LOC.HOSTWHCODE = @cLottable02
					   AND LOC.PutawayZone = @cPAzoneRack
					   AND LOC.LOC NOT IN
					  (@cPAzonePNDRack, @cBuffRk)
					   AND NOT EXISTS (
				  		 SELECT 1
				  		   FROM DBO.LOTxLOCxID AS INV WITH (NOLOCK)
				  		  WHERE INV.LOC = LOC.LOC
				  			AND INV.QTY > 0
					  )
					 ORDER BY LogicalLocation
				   END
            */
			IF @cSuggestedLOC = ''
				BEGIN
					SET @nErrNo = 253564
					SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'253564^QTY > MAXQTY'
					GOTO Quit
				END
			END
		END
	END
END --End 521

IF @nFunc = 523
BEGIN
	-- Get UCC/PLT info
	SELECT @nUCCSkuCnt = COUNT(DISTINCT SKU)
		FROM dbo.UCC WITH (NOLOCK) 
		WHERE StorerKey = @cStorerKey
		AND ID = @cID
		AND Loc = @cLOC
		AND Qty > 0
		AND UCCNO = @cUCCNo

	SELECT @nCubeRequested = @nQty * SKU.STDCUBE,
		   @nSkuCube = SKU.STDCUBE
		  FROM DBO.SKU WITH (NOLOCK)
		 WHERE SKU = @cSKU
		   AND StorerKey = @cStorerKey

	--Get Inv status
	IF ISNULL(@cUCCNo,'') = ''
	BEGIN --PA NoUCC
		SELECT TOP 1 @cLottable02 = LOTATTRIBUTE.lottable02 --ID Same Inv Status as HostWHCode
	    	FROM dbo.LOTxLOCxID WITH (NOLOCK) 
	    	JOIN dbo.LOTATTRIBUTE WITH (NOLOCK) 
	    	  ON LOTATTRIBUTE.LOT = LOTxLOCxID.LOT
	    	 AND LOTATTRIBUTE.StorerKey = LOTxLOCxID.StorerKey
	    	 AND LOTATTRIBUTE.SKU = LOTxLOCxID.SKU
	       WHERE LOTxLOCxID.StorerKey = @cStorerKey
	         AND LOTxLOCxID.ID = @cID
	    	 AND LOTxLOCxID.Loc = @cLoc
			 AND LOTXLOCXID.Sku = @cSKU
	    	 AND LOTxLOCxID.Qty > 0
	END
	ELSE --PA UCC
	BEGIN
		SELECT TOP 1 @cLottable02 = LOTATTRIBUTE.lottable02
			FROM dbo.UCC WITH (NOLOCK) 
			JOIN dbo.LOTATTRIBUTE WITH (NOLOCK) 
			  ON LOTATTRIBUTE.LOT = UCC.LOT
			 AND LOTATTRIBUTE.StorerKey = UCC.StorerKey
			 AND LOTATTRIBUTE.SKU = UCC.SKU
		   WHERE UCC.StorerKey = @cStorerKey
			-- AND ID = @cID
			 AND Loc = @cLoc
			 AND Qty > 0
			 AND UCCNO = @cUCCNo
			 AND UCC.Status = '1'
	END

	-- Lottable02 <> GOO should PA to PNDRACK
	IF @cLottable02 <> @cInvStatus AND @cLOC = @cPAStgIN
	BEGIN
		SET @cSuggestedLOC = @cPAzonePNDRack --Buffer Rack
		GOTO Quit    
	END

	IF @cLOC IN (@cBuffM1, @cBuffM2, @cBuffM3, @cBuffM4, @cBuffRK)
	BEGIN
		SET @nErrNo = 253567
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'Not Allowed'
		GOTO Quit
	END 

 --Get PAZone SKU Single
	SELECT @cFinalLocPAZoneS = ISNULL(MIN(L.PutawayZone),'')
		FROM DBO.SKUxLOC AS PF WITH (NOLOCK)
		JOIN DBO.LOC AS L WITH (NOLOCK) ON L.LOC = PF.LOC
		WHERE PF.QtyLocationLimit > 0
			AND PF.LocationType = 'PICK'
			AND PF.SKU = @cSKU
			AND PF.StorerKey = @cStorerKey

	IF @cFinalLocPAZoneS = ''
	BEGIN
		SET @cSuggestedLOC = ''
		SET @nErrNo = 253563
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'InvalidZone'
		GOTO Quit
	END
	ELSE
	BEGIN
		IF @cFinalLocPAZoneS = 'ONBR_M1'
			SET @cLocBuffer = @cBuffM1
		ELSE IF @cFinalLocPAZoneS = 'ONBR_M2'
			SET @cLocBuffer = @cBuffM2
		ELSE IF @cFinalLocPAZoneS = 'ONBR_M3'
			SET @cLocBuffer = @cBuffM3
		ELSE IF @cFinalLocPAZoneS = 'ONBR_M4'
			SET @cLocBuffer = @cBuffM4
	END

	IF @cLOC = @cPAStgIN AND @cLottable02 = @cInvStatus --Step 1 Should go to Buffer Mezzanine, Lottable02 = GOO
		BEGIN
		   SET @cSuggestedLOC = @cLocBuffer
		   GOTO Quit
		END

	--PICKFACE, allowed only 1 PF for SKU
	--PND Mezzanine
	IF @cLottable02 = @cInvStatus and @cLOC in ( @cPndM1, @cPndM2, @cPndM3, @cPndM4 )
	BEGIN
	SELECT TOP 1
	       @cFinalLocPAZone    = L.PutawayZone,
	       @cSkuPickFace       = PF.LOC, 
		   @nQtyInPickFace     = PF.QTY,
		   @nQtyLimitPickFace  = PF.QtyLocationLimit,
		   @nFullPack          = PACK.CaseCnt,
		   @cHostWHCode        = L.HOSTWHCODE,
		   @nSkuCube           = SKU.STDCUBE
	  FROM DBO.SKUxLOC AS PF WITH (NOLOCK)
	  JOIN DBO.LOC AS L WITH (NOLOCK) ON L.LOC = PF.LOC AND L.Facility = @cFacility
	  JOIN DBO.SKU WITH (NOLOCK) ON SKU.SKU = PF.SKU AND SKU.StorerKey = PF.StorerKey
	  JOIN DBO.PACK WITH (NOLOCK) ON PACK.PackKey = SKU.PACKKey
	 WHERE PF.QtyLocationLimit > 0
	   AND PF.LocationType = 'PICK'
	   AND PF.Sku = @cSKU
	   AND PF.StorerKey = @cStorerKey
	   ORDER BY PF.LOC

	IF @nQty + @nQtyInPickFace <= @nQtyLimitPickFace
	BEGIN
		SET @cSuggestedLOC = @cSkuPickFace
		GOTO Quit
	END
	ELSE --DYNPPICK
	BEGIN
		SELECT TOP 1
			@cSuggestLocTemp = LOC.LOC ,
			@cLogicalLocation = LOC.LogicalLocation,
			@nCubicCapacity =  LOC.CubicCapacity ,
			@nActualCubeLoc = (INV.QTY + INV.PendingMoveIn - (INV.QtyPicked + INV.QtyAllocated)) * SKU.STDCUBE,
			@nCubeRequested = @nQty * SKU.STDCUBE
		FROM DBO.LOTxLOCxID AS INV WITH (NOLOCK)
		JOIN DBO.LOC WITH (NOLOCK)
			ON LOC.LOC = INV.LOC AND LOC.HOSTWHCODE = @cLottable02
		JOIN DBO.SKU WITH (NOLOCK)
			ON SKU.SKU = INV.SKU 
			AND SKU.StorerKey = INV.StorerKey
		WHERE 
			LOC.PutawayZone = @cFinalLocPAZoneS
			AND LOC.FACILITY = @cFacility
			AND INV.SKU = @cSKU
			AND INV.QTY > 0
			AND LOC.LocationType <> 'PICK'
			AND INV.LOC NOT IN (@cLOC, @cSkuPickFace)
			AND ROUND(LOC.CubicCapacity 
						- ((INV.QTY + INV.PendingMoveIn - (INV.QtyPicked + INV.QtyAllocated)) * SKU.STDCUBE)
						- (@nQty * SKU.STDCUBE),
					6) >= 0
		ORDER BY LogicalLocation
			
		IF ISNULL(@cSuggestLocTemp,'') <> ''
		BEGIN
			SET @cSuggestedLOC = @cSuggestLocTemp
			GOTO Quit
		END
		ELSE
		BEGIN
			SELECT TOP 1 @cSuggestLocTemp = LOC.LOC,
						@cLogicalLocation = LOC.LogicalLocation
				FROM DBO.LOC WITH (NOLOCK)
				WHERE LOC.FACILITY = @cFacility
				AND LOC.PutawayZone = @cFinalLocPAZoneS
				AND LOC.HOSTWHCODE = @cLottable02
				AND LOC.LocationType <> 'PICK'
				AND LOC.Status <> 'HOLD' 
				AND LOC.LocationFlag <> 'HOLD'
				AND ROUND(LOC.CubicCapacity - (@nQty * @nSkuCube),6) > 0
				AND LOC.LOC NOT IN (
					SELECT DISTINCT INV.LOC
						FROM DBO.LOTxLOCxID AS INV WITH (NOLOCK)
						WHERE INV.StorerKey = @cStorerKey
						AND INV.QTY > 0 )
			ORDER BY LogicalLocation
				
			IF ISNULL(@cSuggestLocTemp,'') <> ''
				BEGIN
					SET @cSuggestedLOC = @cSuggestLocTemp
					GOTO Quit
				END
			ELSE
			BEGIN
				SET @cSuggestedLOC = ''
				SET @nErrNo = 253565
				SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'253565^QTY > MAXQTY'
				GOTO Quit
			END
		END
		END
	END

	IF @cLottable02 <> @cInvStatus and @cLOC = @cPndRk

	SET @cSuggestLocTemp = ''
	SET @cSuggestedLOC = ''

	BEGIN

		SELECT TOP 1
			@cSuggestLocTemp = LOC.LOC ,
			@cLogicalLocation = LOC.LogicalLocation,
			@nCubicCapacity =  LOC.CubicCapacity
		FROM DBO.LOTxLOCxID AS INV WITH (NOLOCK)
		JOIN DBO.LOC WITH (NOLOCK)
			ON LOC.LOC = INV.LOC AND LOC.HOSTWHCODE = @cLottable02 AND LOC.LocationType = 'BULK' 
		JOIN DBO.SKU WITH (NOLOCK)
			ON SKU.SKU = INV.SKU 
			AND SKU.StorerKey = INV.StorerKey
		WHERE 
			LOC.FACILITY = @cFacility
			AND INV.QTY > 0
			AND INV.LOC <> @cLOC
		GROUP BY LOC.LOC ,
			LOC.LogicalLocation,
			LOC.CubicCapacity
		HAVING ROUND(
			LOC.CubicCapacity 
		  - SUM((INV.QTY + INV.PendingMoveIn - (INV.QtyPicked + INV.QtyAllocated)) * SKU.STDCUBE)
		  - @nCubeRequested,
			6
		  ) >= 0
		ORDER BY LogicalLocation
			
		IF ISNULL(@cSuggestLocTemp,'') <> ''
		BEGIN
			SET @cSuggestedLOC = @cSuggestLocTemp
			GOTO Quit
		END
		ELSE
		BEGIN
			SELECT TOP 1 @cSuggestLocTemp = LOC.LOC,
						@cLogicalLocation = LOC.LogicalLocation, 
						@nCubicCapacity   = LOC.CubicCapacity
				FROM DBO.LOC WITH (NOLOCK)
				WHERE LOC.FACILITY = @cFacility
				AND LOC.LocationType = 'BULK'
				AND LOC.LOC <> @cLOC
				AND LOC.HOSTWHCODE = @cLottable02
				AND ROUND(LOC.CubicCapacity - @nCubeRequested, 6) > 0
				AND LOC.LOC NOT IN (
					SELECT DISTINCT INV.LOC
						FROM DBO.LOTxLOCxID AS INV WITH (NOLOCK)
						WHERE INV.StorerKey = @cStorerKey
						AND INV.QTY > 0 )
			ORDER BY LogicalLocation
			
			IF ISNULL(@cSuggestLocTemp,'') <> ''
				BEGIN
					SET @cSuggestedLOC = @cSuggestLocTemp
					GOTO Quit
				END
			ELSE
			BEGIN
				SET @cSuggestedLOC = ''
				SET @nErrNo = 253566
				SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --'253566^QTY > MAXQTY'
				GOTO Quit
			END
		END
		END
END --END 523
Quit:
IF ISNULL(@nErrNo, 0) <> 0 AND @nFunc = 523
BEGIN
    ;THROW @nErrNo, @cErrMsg, 1; --ErrNo > 5000
END
RETURN
END --END SP
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_521ExtPA99ONBR] TO NSQL
GO

