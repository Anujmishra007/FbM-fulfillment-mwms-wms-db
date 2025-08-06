
/****** Object:  StoredProcedure [RDT].[rdt_825ExtUpdJCB]    Script Date: 8/6/2025 11:27:08 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*****************************************************************************************************/
/* Store procedure: [rdt_825ExtUpdJCB]                                                               */
/* Copyright: Maersk                                                                                 */
/*                                                                                                   */
/* Date         Rev   Author   Purposes                                                              */
/* 31/03/2025   1.0   PPA374   Created                                      	                     */
/* 31/03/2025   1.0   PPA374   Checks the format and gives the error if required                     */
/* 17/06/2025   2.0   PPA374   Updates SKU weight for single SKU pallet                              */
/* 17/06/2025   2.0   PPA374   Updates SKU weight for multi-sku pallet if only one SKU got no weight */
/* 17/06/2025   2.0   PPA374   Checks that dims and weght are within reasonable limits               */
/* 17/06/2025   2.0   PPA374   Update LOTxLOCxID (inventory) for the pallet and same U type pallets  */
/* 17/06/2025   2.0   PPA374   Inserts other non-captured U non-captured pallets (U type)            */
/* 17/06/2025   2.0   PPA374   Updates receipt detail for the pallet and same U type pallets         */
/* 17/06/2025   2.0   PPA374   Not allowing to capture pallet with >1 zero SKUs and not updatng it   */
/* 06/08/2025	2.1   ALT028   Hotfix missing NOLOCK								                 */
/* 06/08/2025   2.2   PPA374   Allowing to measure pallet up to 999 rather than 400                  */
/*****************************************************************************************************/

ALTER    PROC [RDT].[rdt_825ExtUpdJCB] (
   @nMobile      INT,            
   @nFunc        INT,            
   @cLangCode    NVARCHAR( 3),   
   @nStep        INT,            
   @nInputKey    INT,            
   @cStorerKey   NVARCHAR( 15),  
   @cFacility    NVARCHAR( 5),   
   @cPalletKey   NVARCHAR( 30),  
   @cLength      NVARCHAR( 10),  
   @cWidth       NVARCHAR( 10),  
   @cHeight      NVARCHAR( 10),  
   @cWeight      NVARCHAR( 10),  
   @nErrNo       INT           OUTPUT,  
   @cErrMsg      NVARCHAR( 20) OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @nLength        AS float,
   @nWidth         AS float,
   @nHeight        AS float,
   @nWeight        AS float,
   @cPalletType    AS NVARCHAR(20),
   @cReceiptKey    AS NVARCHAR(20),
   @cSKU           AS NVARCHAR(MAX),
   @cZeroExists    AS NVARCHAR(1),
   @cZeroSKU       AS NVARCHAR(20),
   @cUpdateSKU     AS INT,
   @cSetUpdate     AS NVARCHAR(20),
   @cSetMax        AS NVARCHAR(20),
   @cSetSKU1       AS NVARCHAR(20),
   @cSetSKU2       AS NVARCHAR(20),
   @cSetSKU3       AS NVARCHAR(20),
   @cSetSKU4       AS NVARCHAR(20),
   @cSetSKU5       AS NVARCHAR(20),
   @cSetSKU6       AS NVARCHAR(20),
   @cSetSKU7       AS NVARCHAR(20),
   @cSetNotes      AS NVARCHAR(50),
   @nZeroSKUNo     AS INT,
   @nZeroSKUNewW   AS float,
   @cCheckNotes    AS NVARCHAR(20),
   @nDivWeight     AS Float,
   @cInvXRD        AS NVARCHAR(5),
   @cSKUonPal      AS INT

   IF @nFunc = 825
   BEGIN
      IF @nStep = 3 --ID
      BEGIN
	     --Checks if last field = 1 or 0 / blank
         SELECT TOP 1 
		    @cUpdateSKU = I_Field07 
		 FROM RDT.RDTMOBREC WITH(NOLOCK) 
		 WHERE Mobile = @nMobile 

         --Remember entered dims and weight
         SELECT TOP 1 
		    @nLength = Length, 
			@nWidth = Width, 
			@nHeight = Height, 
			@nWeight = GrossWgt 
		 FROM dbo.PALLET WITH(NOLOCK) 
		 WHERE StorerKey = @cStorerKey 
		    AND PalletKey = @cPalletKey
		 
		 SET @cInvXRD = ''

		 --Check if pallet exists in LOTxLOCxID or only RECEIPTDETAIL
         IF EXISTS (
		    SELECT TOP 1 1 
			FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
			WHERE StorerKey = @cStorerKey 
			   AND ToId = @cPalletKey
	     )
		 BEGIN
		    SET @cInvXRD = 'RD' --Pallet is in RECEIPTDETAIL
			SELECT TOP 1 @cReceiptKey = ReceiptKey FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND ToId = @cPalletKey
		 END
		 
		 IF EXISTS (
		    SELECT TOP 1 1 
			FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
			WHERE ID = @cPalletKey 
			   AND StorerKey = @cStorerKey
	     )
		 BEGIN
		    SET @cInvXRD = 'LLI' --Pallet is in the LOTxLOCxID table
		 END

		 IF @cInvXRD = 'LLI'
		 BEGIN
		    SET @cSKUonPal = (SELECT COUNT(DISTINCT SKU) FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) WHERE ID = @cPalletKey AND SKU <> '' AND StorerKey = @cStorerKey)
		 END

		 IF @cInvXRD = 'RD'
		 BEGIN
		    SET @cSKUonPal = (SELECT COUNT(DISTINCT SKU) FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) WHERE ToId = @cPalletKey AND SKU <> '' AND StorerKey = @cStorerKey AND ReceiptKey = @cReceiptKey)
		 END

         IF @nInputKey = 1 --Enter
         BEGIN   
		    SET @nErrNo = 0 --To avoid accidental errors

			IF ISNULL(@cInvXRD,'') = '' --If pallet does not exist in the system
		    BEGIN
		       SET @nErrNo = 218093
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Pallet not exists'
			   DELETE FROM dbo.PALLET WHERE PalletKey = @cPalletKey AND StorerKey = @cStorerKey
			   GOTO QUIT
		    END

			--Checks that there is a SKU without the weight on the PALLET
		    IF EXISTS (
			   SELECT 1 
			   FROM dbo.SKU S WITH(NOLOCK) 
			   WHERE StorerKey = @cStorerKey 
			      AND STDGROSSWGT <= 0 
				  AND (EXISTS (
				     SELECT 1 
					 FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
					 WHERE ToId = @cPalletKey 
					    AND RD.Sku = S.Sku 
						AND StorerKey = @cStorerKey
						AND ReceiptKey = @cReceiptKey
				  )
			      OR EXISTS (
				     SELECT 1 
					 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
					 WHERE ID = @cPalletKey 
					    AND LLI.Sku = S.Sku 
						AND StorerKey = @cStorerKey
			      )
			   )
			)
			BEGIN
			   SET @cZeroExists = 'Y' --Indicating that at least on SKU without weight is on the pallet
			   
			   IF @cInvXRD = 'LLI' --If pallet is in inventory
			   BEGIN
			      --Grabbing the first SKU without weight. Will require for SKU weight update when it is just one SKU without weight.
			      SELECT TOP 1 
				     @cZeroSKU = S.SKU 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
			      ON S.Sku = LLI.Sku
			      WHERE ID = @cPalletKey
			         AND STDGROSSWGT <= 0

			      --Calculating how much SKUs are without the weight. If > 1 then it will not go through and will not be updated.
			      SELECT TOP 1 
				     @nZeroSKUNo = COUNT(DISTINCT S.SKU) 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
			      ON S.Sku = LLI.Sku
			      WHERE ID = @cPalletKey
				     AND S.StorerKey = @cStorerKey
			         AND STDGROSSWGT <= 0

				  SET @nZeroSKUNo = ISNULL(@nZeroSKUNo,0)
			   END

			   IF @cInvXRD = 'RD' --If pallet is not in inventory but in receipt
			   BEGIN
			      --Grabbing the first SKU without weight. Will require for SKU weight update when it is just one SKU without weight.
			      SELECT TOP 1 
				     @cZeroSKU = S.SKU 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.RECEIPTDETAIL RD WITH(NOLOCK)
			      ON S.Sku = RD.Sku
			      WHERE ToId = @cPalletKey
			         AND STDGROSSWGT <= 0
					 AND ReceiptKey = @cReceiptKey
					 AND RD.StorerKey = @cStorerKey

			      --Calculating how much SKUs are without the weight. If > 1 then it will not go through and will not be updated.
			      SELECT TOP 1 
				     @nZeroSKUNo = COUNT(DISTINCT S.SKU) 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.RECEIPTDETAIL RD WITH(NOLOCK)
			      ON S.Sku = RD.Sku
			      WHERE ToId = @cPalletKey
			         AND STDGROSSWGT <= 0
					 AND ReceiptKey = @cReceiptKey
					 AND RD.StorerKey = @cStorerKey

				  SET @nZeroSKUNo = ISNULL(@nZeroSKUNo,0)

			   END
			END
			ELSE
			BEGIN
			   SET @cZeroExists = 'N' --No SKUs without weight (All SKUS got weight)
			END

			--Checking that dims are within reasonable values
		    IF @nLength = '' 
			   OR @nLength < 20 
			   OR @nLength > 999 
			   OR @nWidth = '' 
			   OR @nWidth < 20 
			   OR @nWidth > 999 
			   OR @nHeight = '' 
			   OR @nHeight < 20 
			   OR @nHeight > 999
		    BEGIN
		       SET @nErrNo = 218094
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Dims NOT >=20 <=999'
			   UPDATE dbo.PALLET WITH(ROWLOCK)
               SET Length = 0, 
			      Width = 0, 
				  Height = 0, 
				  GrossWgt = 0, 
				  PalletType = 'U' --Updating pallet type in PALLET as undefined with 0 dims and weight
               WHERE PalletKey = @cPalletKey 
			      AND StorerKey = @cStorerKey
			   
			   UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
			   SET PalletType = 'U' --Updating pallet type in RECEIPTDETAIL as undefined
			   WHERE ToId = @cPalletKey 
			      AND StorerKey = @cStorerKey
				  AND ReceiptKey = @cReceiptKey

			   GOTO QUIT --Stopping the SP
		    END

			IF @nWeight < 20 --Checking that weight is within reasonable value
		    BEGIN
		       SET @nErrNo = 218096
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'Weight is < 20 KG'
			   UPDATE dbo.PALLET WITH(ROWLOCK)
               SET Length = 0, 
			      Width = 0, 
				  Height = 0, 
				  GrossWgt = 0, 
				  PalletType = 'U' --Updating pallet type in PALLET as undefined with 0 dims and weight
               WHERE PalletKey = @cPalletKey 
			      AND StorerKey = @cStorerKey
			   
			   UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
			      SET PalletType = 'U' --Updating pallet type in RECEIPTDETAIL as undefined
			   WHERE ToId = @cPalletKey 
			      AND StorerKey = @cStorerKey
				  AND ReceiptKey = @cReceiptKey

			   GOTO QUIT --Stopping the SP
		    END

		    IF @cZeroExists = 'Y' AND ISNULL(@nZeroSKUNo,0) > 1 --Checks that more than 1 SKU got no weight
		    BEGIN
			   SET @nErrNo = 218095
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'>1 SKU got no weight'
			   UPDATE dbo.PALLET WITH(ROWLOCK)
               SET Length = 0, 
			      Width = 0, 
				  Height = 0, 
				  GrossWgt = 0, 
				  PalletType = 'U'
               WHERE PalletKey = @cPalletKey 
			      AND StorerKey = @cStorerKey
			   
			   UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
			   SET PalletType = 'U'
			   WHERE ToId = @cPalletKey 
			      AND StorerKey = @cStorerKey
				  AND ReceiptKey = @cReceiptKey

			   GOTO QUIT --Stopping the SP
			END

			--Checking weight of the only one unknown SKU for multi-sku pallet
            IF ISNULL(@nZeroSKUNo,0) = 1 
			   AND @cZeroExists = 'Y' 
			   AND @cSKUonPal > 1
		    BEGIN
			   IF @cInvXRD = 'LLI'
               BEGIN
			      --Calculating SKU weight based on total entered weight
			      SELECT TOP 1 
				     @nZeroSKUNewW = (@nWeight-SUM((STDGROSSWGT * Qty))) / SUM(IIF(STDGROSSWGT = 0,Qty,0)) 
                  FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                     INNER JOIN dbo.SKU S WITH(NOLOCK)
                  ON S.Sku = LLI.Sku
                  WHERE S.StorerKey = @cStorerKey
                     AND ID = @cPalletKey

				  IF @nZeroSKUNewW <= 0 --If SKU calculated weight is <= 0
				  BEGIN
				     SET @nErrNo = 218097
					 SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'SKU calc weight <= 0'
						
					 UPDATE dbo.PALLET WITH(ROWLOCK)
                     SET Length = 0, 
					    Width = 0, 
						Height = 0, 
						GrossWgt = 0, 
						PalletType = 'U'
                     WHERE PalletKey = @cPalletKey 
					    AND StorerKey = @cStorerKey
					 GOTO QUIT
				  END

				  ELSE
			      BEGIN
				     UPDATE dbo.SKU WITH(ROWLOCK)
					 SET STDGROSSWGT = @nZeroSKUNewW --Update SKU with new weight
					 WHERE SKU = @cZeroSKU
				  END
               END

          ELSE IF @cInvXRD = 'RD'
			   BEGIN
			      --Calculating SKU weight based on total entered weight
			      SELECT TOP 1 
				     @nZeroSKUNewW = (@nWeight-SUM((STDGROSSWGT * BeforeReceivedQty))) / SUM(IIF(STDGROSSWGT = 0,BeforeReceivedQty,0)) 
                  FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
                     INNER JOIN dbo.SKU S WITH(NOLOCK)
                  ON S.Sku = RD.Sku
                  WHERE S.StorerKey = @cStorerKey
                     AND ToID = @cPalletKey
					 AND ReceiptKey = @cReceiptKey

				  IF @nZeroSKUNewW <= 0 --If SKU calculated weight is <= 0
				  BEGIN
				     SET @nErrNo = 218097
					 SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'SKU calc weight <= 0'
					 
					 UPDATE dbo.PALLET WITH(ROWLOCK)
                     SET Length = 0, 
					    Width = 0, 
						Height = 0, 
						GrossWgt = 0, 
						PalletType = 'U'
                     WHERE PalletKey = @cPalletKey 
					    AND StorerKey = @cStorerKey
				     GOTO QUIT
				  END

				  ELSE
				  BEGIN
				     UPDATE dbo.SKU WITH(ROWLOCK)
					 SET STDGROSSWGT = @nZeroSKUNewW --Update SKU with new weight
					 WHERE SKU = @cZeroSKU
				  END
			   END
			END

			-- Calculating the pallet type and recording entered values
            SELECT TOP 1 
			   @cPalletType = PTM.PalletType, 
			   @nLength = P.Length, 
			   @nWidth = P.Width, 
			   @nHeight = P.Height, 
			   @cWeight = GrossWgt 
			FROM dbo.PalletTypeMaster PTM WITH(NOLOCK)
               INNER JOIN dbo.PALLET P WITH(NOLOCK)
            ON P.Length <= PTM.Length/10 
			   AND P.Width <= PTM.Width/10 
			   AND P.Height <= PTM.Height/10 
			   AND PTM.StorerKey = P.StorerKey
            WHERE PTM.StorerKey = @cStorerKey
               AND Facility = @cFacility
               AND PalletKey = @cPalletKey
               AND PTM.PalletType <> 'M' 
			   AND PTM.PalletTypeInUse='Y' --bug fix to only allow active palet types
            ORDER BY PTM.Length * PTM.Width * PTM.Height

			--Updating Pallet Type based on the above calculation
            UPDATE dbo.PALLET WITH(ROWLOCK)
            SET PalletType = @cPalletType
            WHERE PalletKey = @cPalletKey 
			   AND StorerKey = @cStorerKey

		    --Updating RECEIPTDETIAL table
			UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
			SET PalletType = @cPalletType
			WHERE ToId = @cPalletKey 
			   AND StorerKey = @cStorerKey
			   AND ReceiptKey = @cReceiptKey

			--Updating ID table
			UPDATE dbo.ID WITH(ROWLOCK)
			SET PalletType = @cPalletType
			WHERE ID = @cPalletKey

            SELECT 
               --@cReceiptKey = ReceiptKey, --ASN number
               @cSKU = STRING_AGG(CAST(SKU AS NVARCHAR(MAX)), ', ')WITHIN GROUP(ORDER BY SKU) --SKU list
			FROM (
		       SELECT DISTINCT ToId, 
			      ReceiptKey, 
				  SKU
               FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
			   WHERE StorerKey = @cStorerKey
			   AND ReceiptKey = @cReceiptKey
		    )T1
            WHERE ToId = @cPalletKey 
			   AND ReceiptKey = @cReceiptKey
            GROUP BY ReceiptKey;

			--Identifying all non-finalisd received non-captured pallets to insert
            IF EXISTS (
			   SELECT 1 
			   FROM (
			      SELECT 
                     ToId,
                     STRING_AGG(CAST(SKU AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY SKU) AS SKU
                  FROM (
                     SELECT DISTINCT ToId,
					    SKU
                     FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
					 WHERE StorerKey = @cStorerKey
					    AND @cInvXRD = 'RD'
						AND ToId = @cPalletKey 
			            AND StorerKey = @cStorerKey
			            AND ReceiptKey = @cReceiptKey
				     UNION ALL
					 SELECT DISTINCT ID, 
					    SKU
					 FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
					 WHERE StorerKey = @cStorerKey
					    AND ID = @cPalletKey
					    AND @cInvXRD = 'LLI'
                  ) T1
               WHERE ToId = @cPalletKey
               GROUP BY ToId
               ) T1
               WHERE SKU = @cSKU
			)
            BEGIN
               INSERT INTO PALLET
               SELECT 
                  ToId, 
                  @cStorerKey, 
                  0, 
                  GETDATE(), 
                  GETDATE(), 
                  USER_NAME(), 
                  GETDATE(), 
                  USER_NAME(), 
                  NULL, 
                  NULL, 
                  NULL, 
                  @nLength, 
                  @nWidth, 
                  @nHeight, 
                  LineWeight, --@cWeight
                  @cPalletType 
               FROM (
                  SELECT 
                     T2.ToId,
                     T2.LineWeight,
                     STRING_AGG(CAST(T2.SKU AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY T2.SKU) AS SKU
                  FROM (
                     SELECT 
                        LineWeight,
                        ToID,
                        ReceiptKey,
                        StorerKey,
                        SKU,
                        PalletType
                     FROM (
                        SELECT 
                           SUM(LineWeight) OVER (PARTITION BY ToID) AS LineWeight,
                           ToID,
                           ReceiptKey,
                           StorerKey,
                           SKU,
                           PalletType
                        FROM (
                           SELECT 
                              RD.ToID,
                              S.SKU,
                              RD.PalletType,
                              RD.ReceiptKey,
                              RD.StorerKey,
                              S.STDGROSSWGT * IIF(RD.QtyReceived = 0, RD.BeforeReceivedQty, RD.QtyReceived) AS LineWeight
                           FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
                              INNER JOIN dbo.SKU S WITH(NOLOCK)
                           ON S.SKU = RD.SKU
                           WHERE ISNULL(@nZeroSKUNo,0) <= 1--@cZeroExists = 'N'
                             AND PalletType IN ('U','')
							 AND RD.UserDefine10 = 'Y'
							 AND RD.StorerKey = @cStorerKey
							 AND ReceiptKey = @cReceiptKey
                        ) T4
                     ) T3
                     GROUP BY ToID, ReceiptKey, StorerKey, SKU, PalletType, LineWeight
                  ) T2
                     LEFT JOIN dbo.PALLET P WITH(NOLOCK)
                  ON T2.ToId = P.PalletKey
                  WHERE P.PalletKey IS NULL
                     AND T2.ToId <> @cPalletKey
                     AND T2.StorerKey = @cStorerKey
                     AND T2.ToID <> ''
                  GROUP BY 
                     T2.ToId,
                     T2.LineWeight
               ) T1
               WHERE SKU = @cSKU 
                  AND NOT EXISTS (
                     SELECT 1 
                     FROM dbo.PALLET P WITH(NOLOCK) 
                     WHERE T1.ToId = P.PalletKey
               )

               -- Update receiptdetal pallet type
               UPDATE RD
               SET PalletType = @cPalletType
               FROM dbo.RECEIPTDETAIL RD WITH(ROWLOCK)
                  INNER JOIN (
                     SELECT 
                        --ReceiptKey,
                        PalletType,
                        ToID,
                        STRING_AGG(CAST(SKU AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY SKU) AS SKUList
					 FROM (
					    SELECT DISTINCT PalletType, 
						   ToID, 
						   SKU, 
						   ReceiptKey
                        FROM dbo.RECEIPTDETAIL WITH(NOLOCK)
						WHERE StorerKey = @cStorerKey
						AND ReceiptKey = @cReceiptKey
				     )T1
                     WHERE PalletType IN ('U','') 
					    AND ToID <> '' 
						AND ISNULL(@nZeroSKUNo,0) <= 1
						AND ReceiptKey = @cReceiptKey
           GROUP BY PalletType, 
					    ToID --, ReceiptKey
                  ) Agg 
			   ON RD.PalletType = Agg.PalletType  
                  AND RD.ToID = Agg.ToID
               WHERE Agg.SKUList = @cSKU
			      AND StorerKey = @cStorerKey;

			   -- Updating ID table without pallet type
			   UPDATE ID
               SET PalletType = @cPalletType
               --FROM dbo.ID ID missing NOLOCK
					FROM dbo.ID WITH(NOLOCK) --ALT028
                  INNER JOIN dbo.LOTxLOCxID LLI WITH(ROWLOCK) 
			   ON ID.ID = LLI.ID
                  INNER JOIN (
                     SELECT 
                        ID,
                        STRING_AGG(CAST(SKU AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY SKU) AS SKUList
                     FROM (
                        SELECT DISTINCT ID,
						   SKU
                        FROM dbo.LOTxLOCxID WITH(NOLOCK)
                  ) T1
               GROUP BY ID
               ) Agg 
			   ON Agg.ID = LLI.ID
               WHERE ((ID.PalletType IN ('U','') 
			      AND ID.ID <> '') 
				     OR ID.ID = @cPalletKey)
                  AND Agg.SKUList = @cSKU
                  AND LLI.StorerKey = @cStorerKey
                  AND ISNULL(@nZeroSKUNo,0) <= 1; --@cZeroExists = 'N';

               /*-- Updating ITRN table without pallet type
			   UPDATE ITRN
               SET PalletType = @cPalletType
               FROM dbo.ITRN ITRN WITH(NOLOCK)
                  INNER JOIN dbo.LOTxLOCxID LLI WITH(ROWLOCK) 
			   ON ITRN.ToID = LLI.ID
                  INNER JOIN (
                     SELECT ID,
                        STRING_AGG(CAST(SKU AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY SKU) AS SKUList
                     FROM (
                        SELECT DISTINCT ID, 
						   SKU
                        FROM dbo.LOTxLOCxID WITH(NOLOCK)
                  ) T1
               GROUP BY ID
               ) Agg 
			   ON Agg.ID = LLI.ID
               WHERE ((ITRN.PalletType IN ('U','') 
			      AND ITRN.ToID <> '') 
				  OR ITRN.ToID = @cPalletKey)
                  AND Agg.SKUList = @cSKU
                  AND LLI.StorerKey = @cStorerKey
                  AND ISNULL(@nZeroSKUNo,0) <= 1;--@cZeroExists = 'N';*/

               --Updating SKU with DIMs and dims for inventory (LOTxLOCxID)
			   IF @cInvXRD = 'LLI'
			      AND @cSKUonPal = 1
			      AND (
				     @cUpdateSKU = 1 
				     OR EXISTS(
					    SELECT 1 
						FROM dbo.SKU S WITH(NOLOCK) 
						WHERE S.Sku = @cSKU 
						   AND (STDGROSSWGT = 0 
						      OR Length = 0 
							  OR Width = 0 
							  OR Height = 0 
							  OR ISNULL(Measurement,'') = ''
						   )
					    )
			         )
               BEGIN
			      SELECT @nDivWeight = @nWeight / SUM(Qty)
				  FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                     INNER JOIN dbo.SKU S WITH(NOLOCK)
                  ON S.Sku = LLI.Sku
                  WHERE S.StorerKey = @cStorerKey
                     AND ID = @cPalletKey
				     AND S.Sku = @cSKU
					 AND LLI.Qty > 0

				  UPDATE dbo.SKU WITH(ROWLOCK)
				  SET Length = @nLength, 
					 Width = @nWidth, 
					 Height = @nHeight, 
					 Measurement = @cPalletType, 
					 STDGROSSWGT = @nDivWeight
				  WHERE StorerKey = @cStorerKey
				     AND SKU = @cSKU
               END

               --Updating SKU with DIMs and dims for ASN details (RECEIPTDETAIL)
			   ELSE IF @cInvXRD = 'RD' 
			      AND @cSKUonPal = 1
			      AND (
				     @cUpdateSKU = 1 
					 OR EXISTS(
					    SELECT 1 
						FROM dbo.SKU S WITH(NOLOCK) 
						WHERE S.Sku = @cSKU 
						   AND (
						      STDGROSSWGT = 0 
							  OR Length = 0 
							  OR Width = 0 
							  OR Height = 0 
							  OR ISNULL(Measurement,'') = ''
						   )
					    )
			         )
			   BEGIN
			      SELECT @nDivWeight = @nWeight / SUM(BeforeReceivedQty)
				  FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
                     INNER JOIN dbo.SKU S WITH(NOLOCK)
                  ON S.Sku = RD.Sku
                  WHERE S.StorerKey = @cStorerKey
                     AND ToID = @cPalletKey
					 AND S.SKU = @cSKU
					 AND ReceiptKey = @cReceiptKey
			   
				  UPDATE dbo.SKU WITH(ROWLOCK)
				  SET Length = @nLength, 
				     Width = @nWidth, 
					 Height = @nHeight, 
					 Measurement = @cPalletType, 
					 STDGROSSWGT = @nDivWeight
				  WHERE StorerKey = @cStorerKey
				     AND SKU = @cSKU
               END

			   --Updating SET wth new DIMs and weight
			   ELSE IF @cSKUonPal > 1
			   BEGIN
			      --Capturing SET number and notes
				  SELECT @cSetUpdate = Code, 
				     @cCheckNotes = Notes 
				  FROM (
				     SELECT Code, 
					 Description, 
					 Notes, 
					 STRING_AGG(Value, ', ') WITHIN GROUP (ORDER BY Value)SKUSET
                  FROM (
                     SELECT Short AS Value, 
					    Description, 
						Code, 
						Notes 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Storerkey = @cStorerKey
                     UNION
                     SELECT Long, 
					    Description, 
						Code, 
						Notes 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Storerkey = @cStorerKey
                     UNION
                     SELECT UDF01, 
					    Description, 
						Code, 
						Notes 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Storerkey = @cStorerKey
                     UNION
                     SELECT UDF02, 
					    Description, 
						Code, 
						Notes 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Storerkey = @cStorerKey
                     UNION
                     SELECT UDF03, 
					    Description, 
						Code, 
						Notes 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Storerkey = @cStorerKey
                     UNION 
                     SELECT UDF04, 
					    Description, 
						Code, 
						Notes 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Storerkey = @cStorerKey
                     UNION 
                     SELECT UDF05, 
					    Description, 
						Code, 
						Notes 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Storerkey = @cStorerKey
                  ) AS AllValues
                  WHERE Value IS NOT NULL 
				     AND LTRIM(RTRIM(Value)) <> ''
                  GROUP BY Description, Code, Notes)T1
				  WHERE SKUSET = @cSKU

                  --Creating new notes
				  SET @cSetNotes = CAST(@nLength AS NVARCHAR(20)) + ',' + CAST(@nWidth AS NVARCHAR(20)) + ',' + CAST(@nHeight AS NVARCHAR(20)) + ',' + CAST(@nWeight AS NVARCHAR(20))

				  --Updating set if notes got 0 DIM / weight or user asked for an update
   				  IF (
				     SELECT CHARINDEX(',0,',','+@cCheckNotes+',',1)) > 0 
					    OR (ISNULL(@cSetUpdate,'') <> '' 
						AND @cUpdateSKU = 1
				  )
				  BEGIN
				     UPDATE CODELKUP WITH(ROWLOCK)
				     SET Notes = @cSetNotes, 
					    Description = @cPalletType
				     WHERE Storerkey = @cStorerKey 
					    AND Code = @cSetUpdate
				  END

				  --If SET for SKUs does not exist and SET got no more than 7 SKUs, then insert it
				  ELSE IF (
				     LEN(@cSKU) - LEN(REPLACE(@cSKU, ',', '')) <= 6) 
					    AND ISNULL(@cSetUpdate,''
				  ) = ''
				  BEGIN
				     --Finding next SET number to use
				     SELECT @cSetMax = 'SET'+CAST(SUBSTRING(MAX(Code),4,6)+1 AS NVARCHAR(10)) 
					 FROM dbo.CODELKUP WITH(NOLOCK) 
					 WHERE LISTNAME = 'JCBSKUPAL' 
					    AND Code LIKE 'SET%'

					 --Splitting SKU string into individual SKUs
				     ;WITH Split AS (
                     SELECT 
                        TRIM(Value)Value,
                        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
                     FROM STRING_SPLIT(@csku, ',')
                     )

					 --Assigning each split SKU to an individual SKU field
				     SELECT @cSetSKU1 = ISNULL(MAX(CASE WHEN rn = 1 THEN value END),''),
                        @cSetSKU2 = ISNULL(MAX(CASE WHEN rn = 2 THEN value END),''),
                        @cSetSKU3 = ISNULL(MAX(CASE WHEN rn = 3 THEN value END),''),
                        @cSetSKU4 = ISNULL(MAX(CASE WHEN rn = 4 THEN value END),''),
                        @cSetSKU5 = ISNULL(MAX(CASE WHEN rn = 5 THEN value END),''),
                        @cSetSKU6 = ISNULL(MAX(CASE WHEN rn = 6 THEN value END),''),
                        @cSetSKU7 = ISNULL(MAX(CASE WHEN rn = 7 THEN value END),'')
                     FROM Split;

					 --Inserting new SET data
				     INSERT INTO CODELKUP (LISTNAME, Code, Description, Short, Long, Notes, AddDate, AddWho, EditDate, EditWho, TrafficCop, Notes2, Storerkey, UDF01, UDF02, UDF03, UDF04, UDF05, code2)
				     VALUES ('JCBSKUPAL', @cSetMax, @cPalletType, ISNULL(@cSetSKU6,''), ISNULL(@cSetSKU7,''), @cSetNotes, GETDATE(), USER_NAME(), GETDATE(), USER_NAME(), NULL, '', @cStorerKey, ISNULL(@cSetSKU1,''), ISNULL(@cSetSKU2,''), ISNULL(@cSetSKU3,''), ISNULL(@cSetSKU4,''), ISNULL(@cSetSKU5,''), '')
                  END
			   END
            END
		 END
      END
   END
QUIT:
END

GO
GRANT EXECUTE ON [RDT].[rdt_825ExtUpdJCB] TO [NSQL]
GO
