SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO








/************************************************************************/
/* Store procedure: rdt_664ExtInfo04_SKF                    			*/
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Suggest location using putaway strategy for SKF				*/
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2025-10-06 1.0  SYO054  Created for putaway strategy suggestion      */
/************************************************************************/

CREATE                 PROC [RDT].[rdt_664ExtInfo04_SKF]
   @nMobile         INT,
   @nFunc           INT,
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,
   @nInputKey       INT,
   @cStorerKey      NVARCHAR( 15),
   @cID             NVARCHAR( 18),              
   @cFromLOC        NVARCHAR( 10),              
   @cToLOC          NVARCHAR( 10),              
   @cSKU            NVARCHAR( 20),              
   @cReceiptKey     NVARCHAR( 10),              
   @cReceiptLineNumber NVARCHAR( 10),        
   @cOutText1       NVARCHAR( 20) OUTPUT,     
   @cOutText2       NVARCHAR( 20) OUTPUT,     
   @cOutText3       NVARCHAR( 20) OUTPUT,
   @nErrNo          INT OUTPUT,              
   @cErrMsg         NVARCHAR( 20) OUTPUT      
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cSuggestedLOC NVARCHAR(10) = ''
   DECLARE @cLOT NVARCHAR(10) = ''
   DECLARE @cPutawayStrategyKey NVARCHAR(10) = ''
   DECLARE @cFacility NVARCHAR(5) = ''
   DECLARE @cPAType NVARCHAR(5) = ''
   DECLARE @cZone NVARCHAR(10) = ''
   DECLARE @cFromLocStrategy NVARCHAR(10) = ''
   DECLARE @cToLocStrategy NVARCHAR(10) = ''
   DECLARE @cSuggLocEnable NVARCHAR(10) = ''
   DECLARE @n_StdGrossWgt FLOAT
   DECLARE @cInbStageLoc NVARCHAR( 10)
   DECLARE @cDamagePutawayZone NVARCHAR(20)

   SET @nErrNo = 0
   SET @cOutText1 = ''
   SET @cOutText2 = ''
   SET @cOutText3 = ''

   SELECT @cInbStageLoc = SValue 
   FROM rdt.StorerConfig 
   WHERE Function_ID = '664' AND StorerKey = @cStorerKey AND ConfigKey = 'InbStageLoc' 

   SELECT @cDamagePutawayZone = SValue 
   FROM rdt.StorerConfig 
   WHERE Function_ID = '664' AND StorerKey = @cStorerKey AND ConfigKey = 'DamagePutawayZone' 

   -- Check if suggestion is enabled
   SELECT @cSuggLocEnable = SValue 
   FROM rdt.StorerConfig WITH (NOLOCK)
   WHERE Function_ID = '664' AND storerkey = @cStorerKey AND ConfigKey = 'SuggLocEnable'

   IF @cSuggLocEnable = '1' AND @nFunc = 664 AND @nStep = 3
   BEGIN
      -- Get facility
      SELECT @cFacility = Facility FROM LOC WITH (NOLOCK) WHERE LOC = @cFromLOC

      -- Get SKU info
      IF @cSKU = '' OR @cSKU IS NULL
      BEGIN
         SELECT TOP 1 @cSKU = SKU
         FROM RECEIPTDETAIL WITH (NOLOCK)
         WHERE ToID = @cID AND ToLoc = @cFromLOC AND QTYExpected > 0
      END

      -- Get SKU weight
      SELECT @n_StdGrossWgt = ISNULL(StdGrossWgt, 0)
      FROM SKU WITH (NOLOCK)
      WHERE StorerKey = @cStorerKey AND SKU = @cSKU

      -- Get putaway strategy
      SELECT @cPutawayStrategyKey = ST.PutawayStrategyKey
      FROM SKU S WITH (NOLOCK)
         JOIN Strategy ST WITH (NOLOCK) ON S.StrategyKey = ST.StrategyKey
      WHERE S.StorerKey = @cStorerKey AND S.SKU = @cSKU

      -- Process putaway strategy lines in order
      DECLARE strategy_cursor CURSOR FOR
      SELECT PAType, ISNULL(FromLoc,''), ISNULL(ToLoc,''), ISNULL(Zone,'')
      FROM PUTAWAYSTRATEGYDETAIL WITH (NOLOCK)
      WHERE PutAwayStrategyKey = @cPutawayStrategyKey
      ORDER BY putawaystrategylinenumber

      OPEN strategy_cursor
      FETCH NEXT FROM strategy_cursor INTO @cPAType, @cFromLocStrategy, @cToLocStrategy, @cZone

      WHILE @@FETCH_STATUS = 0 AND @cSuggestedLOC = ''
      BEGIN
         IF @cPAType = '01' -- If Source=FROMLOCATION, Putaway to TOLOCATION
         BEGIN
            IF @cFromLOC = @cFromLocStrategy AND @cToLocStrategy <> ''
               SET @cSuggestedLOC = @cToLocStrategy
         END
         ELSE IF @cPAType = '02' -- IF source is FROMLOC then move to a location within the specified zone
         BEGIN
            IF @cFromLOC = @cFromLocStrategy
            BEGIN
               SELECT TOP 1 @cSuggestedLOC = LOC
               FROM LOC L WITH (NOLOCK)
               WHERE L.Facility = @cFacility AND L.PutawayZone = @cZone
                  AND NOT EXISTS(SELECT 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE LOC = L.LOC AND QTY > 0)
                  AND (SELECT COUNT(DISTINCT LLI.Id)
                       FROM LOTxLOCxID LLI WITH (NOLOCK)
                       WHERE LLI.Loc = L.Loc
                       AND (LLI.QTY > 0 OR LLI.PendingMoveIN > 0)) < L.MaxPallet
               ORDER BY L.PALogicalLoc, L.LOC
            END
         END
         ELSE IF @cPAType = '03' -- If Source=FromLOCATION, Putaway to Pick Location
         BEGIN
            IF @cFromLOC = @cFromLocStrategy
            BEGIN
               SELECT TOP 1 @cSuggestedLOC = LOC
               FROM SKUxLOC WITH (NOLOCK)
               WHERE StorerKey = @cStorerKey AND SKU = @cSKU AND LocationType IN ('PICK','CASE')
            END
         END
         ELSE IF @cPAType = '04' -- Search ZONE specified on this strategy record
         BEGIN
            SELECT TOP 1 @cSuggestedLOC = LOC
            FROM LOC L WITH (NOLOCK)
            WHERE L.Facility = @cFacility AND L.PutawayZone = @cZone
               AND NOT EXISTS(SELECT 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE LOC = L.LOC AND QTY > 0)
               AND (SELECT COUNT(DISTINCT LLI.Id)
                    FROM LOTxLOCxID LLI WITH (NOLOCK)
                    WHERE LLI.Loc = L.Loc
                    AND (LLI.QTY > 0 OR LLI.PendingMoveIN > 0)) < L.MaxPallet
            ORDER BY L.PALogicalLoc, L.LOC
         END
         ELSE IF @cPAType = '12' -- Search ZONE specified in sku table
         BEGIN
            SELECT @cZone = Zone FROM PUTAWAYSTRATEGYDETAIL WITH (NOLOCK) WHERE PutAwayStrategyKey = @cPutawayStrategyKey AND PAType = @cPAType
            IF @cZone IS NULL OR @cZone = ''
               SELECT @cZone = PutawayZone FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
            SELECT TOP 1 @cSuggestedLOC = LOC
            FROM LOC L WITH (NOLOCK)
            WHERE L.Facility = @cFacility AND L.PutawayZone = @cZone
               AND NOT EXISTS(SELECT 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE LOC = L.LOC AND QTY > 0)
               AND (SELECT COUNT(DISTINCT LLI.Id)
                    FROM LOTxLOCxID LLI WITH (NOLOCK)
                    WHERE LLI.Loc = L.Loc
                    AND (LLI.QTY > 0 OR LLI.PendingMoveIN > 0)) < L.MaxPallet
            ORDER BY L.PALogicalLoc, L.LOC
         END
         ELSE IF @cPAType = '16' -- Search Location With the same Sku and Lottable10 Within Sku Zone
         BEGIN
            -- Calculate pallet weight
            SELECT @n_StdGrossWgt = RD.BeforeReceivedQty * S.StdGrossWgt
            FROM RECEIPTDETAIL RD WITH (NOLOCK)
            JOIN SKU S WITH (NOLOCK) ON RD.SKU = S.SKU AND RD.StorerKey = S.StorerKey
            WHERE RD.ToId = @cID

            IF EXISTS(SELECT 1 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE ToID = @cID AND ConditionCode = 'OK')
            BEGIN
               SELECT @cZone = Zone FROM PUTAWAYSTRATEGYDETAIL WITH (NOLOCK) WHERE PutAwayStrategyKey = @cPutawayStrategyKey AND PAType = @cPAType
               IF @cZone IS NULL OR @cZone = ''
                  SELECT @cZone = PutawayZone FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
               
               -- First check: If SKU, lottable10, storerkey combination exists with FinalizeFlag = 'N' , ToLoc <> @cInbStageLoc AND less than MaxPallet configured
				SELECT TOP 1 @cSuggestedLOC = RD.ToLoc
				FROM RECEIPTDETAIL RD WITH (NOLOCK)
				JOIN LOC L WITH (NOLOCK) ON RD.ToLoc = L.LOC
				WHERE RD.SKU = @cSKU 
				   AND RD.StorerKey = @cStorerKey 
				   AND RD.Lottable10 = (SELECT Lottable10 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE SKU = @cSKU AND StorerKey = @cStorerKey AND RECEIPTDETAIL.ToId = @cID)
				   AND RD.FinalizeFlag = 'N'
				   AND RD.ToLoc <> @cInbStageLoc
				   AND UPPER(L.LOCATIONFLAG) = 'NONE'
                   AND (L.WeightCapacity >= @n_StdGrossWgt + 
                                    ISNULL((SELECT SUM((LLI2.QTY - LLI2.QtyPicked + LLI2.PendingMoveIN) * S2.StdGrossWgt) 
                                        FROM LOTxLOCxID LLI2 WITH (NOLOCK) 
                                        JOIN SKU S2 WITH (NOLOCK) ON LLI2.SKU = S2.SKU AND LLI2.StorerKey = S2.StorerKey
                                        WHERE LLI2.LOC = L.LOC AND LLI2.SKU = @cSKU AND LLI2.StorerKey = @cStorerKey), 0) +
                                    ISNULL((SELECT SUM(RD2.BeforeReceivedQty * S3.StdGrossWgt)
                                        FROM RECEIPTDETAIL RD2 WITH (NOLOCK)
                                        JOIN SKU S3 WITH (NOLOCK) ON RD2.SKU = S3.SKU AND RD2.StorerKey = S3.StorerKey
                                        WHERE RD2.ToLoc = L.LOC AND RD2.FinalizeFlag = 'N' AND RD2.SKU = @cSKU AND RD2.StorerKey = @cStorerKey), 0)) 

				   AND (SELECT COUNT(DISTINCT ToId) FROM RECEIPTDETAIL WITH (NOLOCK) WHERE RECEIPTDETAIL.ToLoc = RD.ToLoc AND RECEIPTDETAIL.FinalizeFlag = 'N' AND RECEIPTDETAIL.ToLoc <> @cInbStageLoc) < ISNULL(L.MaxPallet, 999999)	


					-- If no suggestion found, use original logic
					IF @cSuggestedLOC = ''
					BEGIN
					   DECLARE @cConditionCode VARCHAR(10)
   
					   -- Get ConditionCode from RECEIPTDETAIL
					   SELECT @cConditionCode = ConditionCode 
					   FROM RECEIPTDETAIL WITH (NOLOCK) 
					   WHERE SKU = @cSKU AND StorerKey = @cStorerKey AND ToId = @cID

					   IF @cConditionCode <> 'OK'
					   BEGIN
						  SELECT TOP 1 @cSuggestedLOC = LOC
						  FROM LOC WITH (NOLOCK)
						  WHERE Facility = @cFacility AND PutawayZone = @cDamagePutawayZone
					   END
					   ELSE
					   BEGIN
						  SELECT TOP 1 @cSuggestedLOC = L.LOC
                            FROM LOTxLOCxID LLI WITH (NOLOCK)
                            JOIN LOC L WITH (NOLOCK) ON LLI.LOC = L.LOC
                            JOIN RECEIPTDETAIL RD WITH (NOLOCK) ON RD.SKU = LLI.SKU AND RD.StorerKey = LLI.StorerKey
                            LEFT JOIN SKU S WITH (NOLOCK) ON LLI.SKU = S.SKU AND LLI.StorerKey = S.StorerKey
                            JOIN LOTATTRIBUTE LA WITH (NOLOCK) ON LA.Lot = LLI.Lot AND LA.Sku = LLI.Sku AND LA.StorerKey = LLI.StorerKey AND LA.Lottable10 = RD.Lottable10
                            WHERE LLI.SKU = @cSKU AND LLI.StorerKey = @cStorerKey AND (LLI.QTY > 0 OR LLI.PendingMoveIN > 0)
                            AND RD.Lottable10 = (SELECT Lottable10 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE SKU = @cSKU AND StorerKey = @cStorerKey AND RECEIPTDETAIL.ToId = @cID)
                            AND L.Facility = @cFacility AND L.PutawayZone = @cZone
                            AND S.ABC = L.ABC
                            AND (SELECT COUNT(DISTINCT Id) FROM LOTxLOCxID WITH (NOLOCK) WHERE LOC = L.LOC AND (QTY > 0 OR PendingMoveIN > 0)) < L.MaxPallet
                            AND (L.WeightCapacity >= @n_StdGrossWgt + 
                                    ISNULL((SELECT SUM((LLI2.QTY - LLI2.QtyPicked + LLI2.PendingMoveIN) * S2.StdGrossWgt) 
                                        FROM LOTxLOCxID LLI2 WITH (NOLOCK) 
                                        JOIN SKU S2 WITH (NOLOCK) ON LLI2.SKU = S2.SKU AND LLI2.StorerKey = S2.StorerKey
                                        WHERE LLI2.LOC = L.LOC AND LLI2.SKU = @cSKU AND LLI2.StorerKey = @cStorerKey), 0) +
                                    ISNULL((SELECT SUM(RD2.BeforeReceivedQty * S3.StdGrossWgt)
                                        FROM RECEIPTDETAIL RD2 WITH (NOLOCK)
                                        JOIN SKU S3 WITH (NOLOCK) ON RD2.SKU = S3.SKU AND RD2.StorerKey = S3.StorerKey
                                        WHERE RD2.ToLoc = L.LOC AND RD2.FinalizeFlag = 'N' AND RD2.SKU = @cSKU AND RD2.StorerKey = @cStorerKey), 0))
                            AND NOT EXISTS (SELECT 1 FROM RECEIPTDETAIL RD2 WITH (NOLOCK) WHERE RD2.StorerKey = @cStorerKey AND RD2.ToLoc = L.Loc AND RD2.FinalizeFlag = 'N' AND RD2.ToLoc <> @cInbStageLoc)
                            AND UPPER(L.LOCATIONFLAG) = 'NONE'
                            ORDER BY L.PALogicalLoc, L.LOC
					   END
					END


            END
			IF EXISTS(SELECT 1 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE ToID = @cID AND ConditionCode <> 'OK')
								   BEGIN
						  SELECT TOP 1 @cSuggestedLOC = LOC
						  FROM LOC WITH (NOLOCK)
						  WHERE Facility = @cFacility AND PutawayZone = @cDamagePutawayZone
					   END
         END
         ELSE IF @cPAType = '17' -- Search Empty Location Within Sku Zone
         BEGIN
            -- Calculate pallet weight
            SELECT @n_StdGrossWgt = RD.BeforeReceivedQty * S.StdGrossWgt
            FROM RECEIPTDETAIL RD WITH (NOLOCK)
            JOIN SKU S WITH (NOLOCK) ON RD.SKU = S.SKU AND RD.StorerKey = S.StorerKey
            WHERE RD.ToId = @cID

            IF EXISTS(SELECT 1 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE ToID = @cID AND ConditionCode = 'OK')
            BEGIN
               SELECT @cZone = Zone FROM PUTAWAYSTRATEGYDETAIL WITH (NOLOCK) WHERE PutAwayStrategyKey = @cPutawayStrategyKey AND PAType = @cPAType
				IF @cZone IS NULL OR @cZone = ''
				   SELECT @cZone = PutawayZone FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU
				SELECT TOP 1 @cSuggestedLOC = L.LOC
				FROM LOC L WITH (NOLOCK)
				JOIN SKU S WITH (NOLOCK) ON S.StorerKey = @cStorerKey AND S.SKU = @cSKU			   
				WHERE L.Facility = @cFacility AND L.PutawayZone = @cZone
				   AND S.ABC = L.ABC
				   AND NOT EXISTS(SELECT 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE LOC = L.LOC )
				   AND (SELECT COUNT(DISTINCT LLI.Id)
						 FROM LOTxLOCxID LLI WITH (NOLOCK)
						 WHERE LLI.Loc = L.Loc
						 AND (LLI.QTY > 0 OR LLI.PendingMoveIN > 0)) < L.MaxPallet
				   AND (L.WeightCapacity >= @n_StdGrossWgt + 
                                    ISNULL((SELECT SUM((LLI2.QTY - LLI2.QtyPicked + LLI2.PendingMoveIN) * S2.StdGrossWgt) 
                                        FROM LOTxLOCxID LLI2 WITH (NOLOCK) 
                                        JOIN SKU S2 WITH (NOLOCK) ON LLI2.SKU = S2.SKU AND LLI2.StorerKey = S2.StorerKey
                                        WHERE LLI2.LOC = L.LOC AND LLI2.SKU = @cSKU AND LLI2.StorerKey = @cStorerKey), 0) +
                                    ISNULL((SELECT SUM(RD2.BeforeReceivedQty * S3.StdGrossWgt)
                                        FROM RECEIPTDETAIL RD2 WITH (NOLOCK)
                                        JOIN SKU S3 WITH (NOLOCK) ON RD2.SKU = S3.SKU AND RD2.StorerKey = S3.StorerKey
                                        WHERE RD2.ToLoc = L.LOC AND RD2.FinalizeFlag = 'N' AND RD2.SKU = @cSKU AND RD2.StorerKey = @cStorerKey), 0)) 
				   AND NOT EXISTS (SELECT 1 FROM RECEIPTDETAIL RD2 WITH (NOLOCK) WHERE RD2.StorerKey = @cStorerKey AND RD2.ToLoc = L.Loc AND RD2.FinalizeFlag = 'N' AND RD2.ToLoc <> @cInbStageLoc)
				   AND UPPER(L.LOCATIONFLAG) = 'NONE'
				ORDER BY L.PALogicalLoc, L.LOC
            END
         END
         ELSE IF @cPAType = '59' -- IF ID Held, PUT TO Specified ZONE
         BEGIN
            IF EXISTS(SELECT 1 FROM RECEIPTDETAIL WITH (NOLOCK) WHERE ToID = @cID AND ConditionCode IN ('DAMAGE','DM'))
            BEGIN
               --Get the Putaway Zone. First look for the Putaway Zone from PUTAWAYSTRATEGYDETAIL
               --If Zone is Empty then search for the Putaway Zone from SKU
                 SELECT @cZone = Zone FROM PUTAWAYSTRATEGYDETAIL WITH (NOLOCK) WHERE PutAwayStrategyKey = @cPutawayStrategyKey AND PAType = @cPAType
               --IF @cZone IS NULL OR @cZone = ''
                --SELECT @cZone = PutawayZone FROM SKU WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND SKU = @cSKU

               SELECT TOP 1 @cSuggestedLOC = LOC
				FROM LOC WITH (NOLOCK)
				WHERE Facility = @cFacility AND PutawayZone = @cZone
			   AND NOT EXISTS(SELECT 1 FROM LOTxLOCxID WITH (NOLOCK) WHERE LOC = LOC.LOC AND QTY > 0)
			   AND UPPER(LOCATIONFLAG) = 'NONE'
				ORDER BY PALogicalLoc, LOC	

            END
         END

         FETCH NEXT FROM strategy_cursor INTO @cPAType, @cFromLocStrategy, @cToLocStrategy, @cZone
      END

      CLOSE strategy_cursor
      DEALLOCATE strategy_cursor

      -- Set output
      IF @cSuggestedLOC <> ''
         SET @cOutText1 = @cSuggestedLOC
      ELSE
         SET @cOutText1 = 'No suitable LOC'	      
   END
END
GO
