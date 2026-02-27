
/****** Object:  StoredProcedure [RDT].[rdt_825ExtScnJCB]    Script Date: 7/15/2025 5:27:38 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_825ExtScnJCB                                    */
/*                                                                      */
/* Purpose:       For JCB                                               */
/*                                                                      */
/* Date         Rev   Author   Purposes                                 */
/* 31/03/2025   1.0   PPA374   Created - Calculating weight             */
/* 17/06/2025   2.0   PPA374   Added notifications for the user         */
/************************************************************************/  
  
CREATE OR ALTER   PROC  [RDT].[rdt_825ExtScnJCB] (
   @nMobile          INT,           
   @nFunc            INT,           
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,           
   @nScn             INT,           
   @nInputKey        INT,           
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15), 
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,  
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT, 
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT, 
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT, 
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT, 
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT, 
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT, --0 Jump Screen, 1 Validation(pass through all input fields), 2 Update, 3 Prepare output fields .....
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
   @cLPN         AS NVARCHAR(20),
   @nTotalWeight AS float,
   @cInvXRD AS NVARCHAR(20)

   SET @nAfterScn = @nScn
   SET @nAfterStep = @nStep

   IF @nFunc = 825
   BEGIN
      IF @nStep = 3
      BEGIN         
         IF @nInputKey = 1
         BEGIN
		    SELECT TOP 1 @cLPN = I_Field01 
			FROM RDT.RDTMOBREC WITH(NOLOCK) 
			WHERE Mobile = @nMobile

			--Check if pallet exists in LOTxLOCxID or only RECEIPTDETAIL
		    IF EXISTS (
			   SELECT 1 
			   FROM dbo.LOTxLOCxID LLI WITH(NOLOCK) 
			   WHERE ID = @cLPN 
			      AND StorerKey = @cStorerKey
			)
		    BEGIN
		       SET @cInvXRD = 'LLI' --Pallet is in the LOTxLOCxID table
		    END

		    ELSE IF EXISTS (
			   SELECT 1 
			   FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
			   WHERE StorerKey = @cStorerKey 
			      AND ToId = @cLPN
			)
		    BEGIN
		       SET @cInvXRD = 'RD' --Pallet is NOT in the LOTxLOCxID table but is in RECEIPTDETAIL
		    END

		    ELSE
		    BEGIN
		       SET @cInvXRD = '' --Pallet does not exist in either table
		    END

		    IF @cInvXRD = '' --If pallet does not exist in the system
		    BEGIN
		       SET @nErrNo = 218230
			   SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')--'Pallet not exists'
		    END

			IF @cInvXRD = 'LLI'
			BEGIN
			   SELECT TOP 1 
			      @nTotalWeight = SUM(Qty * CAST(STDGROSSWGT AS float)) 
			   FROM (
			      SELECT LLI.SKU, 
				     Qty, 
					 STDGROSSWGT 
				  FROM dbo.LOTxLOCxID LLI WITH(NOLOCK)
                     INNER JOIN SKU S WITH(NOLOCK)
                  ON LLI.Sku = S.Sku
                  WHERE LLI.StorerKey = @cStorerKey
                     AND ID = @cLPN
			   )T1

			   IF (
			      SELECT TOP 1 
				     COUNT(DISTINCT S.SKU) 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
			      ON S.Sku = LLI.Sku
			      WHERE ID = @cLPN
				     AND S.StorerKey = @cStorerKey
			         AND STDGROSSWGT <= 0
			   ) = 1
			   BEGIN
			      SET @nTotalWeight = 0
				  SET @cErrMsg = 'One SKU no weight' --Information for the user
			   END

			   IF (
			      SELECT TOP 1 
				     COUNT(DISTINCT S.SKU) 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.LOTxLOCxID LLI WITH(NOLOCK)
			      ON S.Sku = LLI.Sku
			      WHERE ID = @cLPN
				     AND S.StorerKey = @cStorerKey
			         AND STDGROSSWGT <= 0) > 1
			   BEGIN
			      SET @nTotalWeight = 0
				  SET @nErrNo = 218231
			      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'>1 SKU got no weight'
			   END
			END

			ELSE IF @cInvXRD = 'RD'
			BEGIN
			   SELECT TOP 1 
			      @nTotalWeight = SUM(BeforeReceivedQty * CAST(STDGROSSWGT AS float)) 
			   FROM (
			      SELECT 
				     RD.SKU, 
					 BeforeReceivedQty, 
					 STDGROSSWGT 
				  FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK)
                     INNER JOIN dbo.SKU S WITH(NOLOCK)
                  ON RD.Sku = S.Sku
                  WHERE RD.StorerKey = @cStorerKey
                     AND ToId = @cLPN
			   )T1

			   IF (
			      SELECT TOP 1 
				     COUNT(DISTINCT S.SKU) 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.RECEIPTDETAIL RD WITH(NOLOCK)
			      ON S.Sku = RD.Sku
			      WHERE ToId = @cLPN
				     AND S.StorerKey = @cStorerKey
			         AND STDGROSSWGT <= 0
			   ) = 1
			   BEGIN
			      SET @nTotalWeight = 0
				  SET @nErrNo = 218232
				  SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'One SKU no weight'
			   END

			   IF (
			      SELECT TOP 1 
				     COUNT(DISTINCT S.SKU) 
				  FROM dbo.SKU S WITH(NOLOCK) 
			         INNER JOIN dbo.RECEIPTDETAIL RD WITH(NOLOCK)
			      ON S.Sku = RD.Sku
			      WHERE ToId = @cLPN
				     AND S.StorerKey = @cStorerKey
			         AND STDGROSSWGT <= 0
			   ) > 1
			   BEGIN
			      SET @nTotalWeight = 0
				  SET @nErrNo = 218231
			      SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'>1 SKU got no weight'
			   END
			END

			ELSE
			BEGIN
			   SET @nTotalWeight = 0
			END

            -- total sku weight
            SET @cOutField05 = ISNULL(@nTotalWeight,0)
         END            
      END
   END   
END

GO
GRANT EXECUTE ON [RDT].[rdt_825ExtScnJCB] TO [NSQL]
GO
