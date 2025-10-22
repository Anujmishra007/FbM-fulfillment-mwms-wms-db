SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt.rdt_GETSKU_HILLSHK                              */
/* Copyright      : Maersk                                              */
/*Customer        : HILLSHK                                             */
/*                                                                      */
/* Purpose: SKU Code Lookup (SKU/ManufacturerSKU/RetailSKU/AltSKU       */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 2025-08-08  1.0  NickT    FCR-5535 Created, base on rdt_GETSKU       */
/************************************************************************/
CREATE OR ALTER PROC    [RDT].[rdt_GETSKU_HILLSHK]
               @cStorerKey   NVARCHAR(15)
,              @cSKU         NVARCHAR(30)      OUTPUT -- (ung01)
,              @bSuccess     int               OUTPUT
,              @nErr         int               OUTPUT
,              @cErrMsg      NVARCHAR(250)     OUTPUT
,              @cSKUStatus   NVARCHAR(10) = ''
,              @nUPCQTY      INT = 0           OUTPUT

AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nContinue   INT
   DECLARE @cLangCode   NVARCHAR( 3)
   DECLARE @nFunc       INT
   DECLARE @nQTY        INT = 0
   DECLARE @cUOM        NVARCHAR( 10)
   
   SELECT @nContinue = 1
   SELECT @bSuccess = 1
   SELECT @nErr = 0

   IF @cSKUStatus = ''
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(PKSKU)) 
                     WHERE StorerKey = @cStorerKey AND Sku = @cSKU)
      BEGIN
         SELECT TOP 1 
            @cSKU = UPC.SKU, 
            @cUOM = UPC.UOM, 
            @nQTY = ISNULL( UPC.QTY, 0)
         FROM dbo.UPC UPC WITH (NOLOCK) 
         WHERE UPC = @cSKU 
            AND StorerKey = @cStorerKey

         IF @@ROWCOUNT = 0 
         BEGIN 
            SELECT TOP 1 @cSKU = SKU 
            FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(IX_SKU_AltSku)) 
            WHERE AltSku = @cSKU 
            AND StorerKey = @cStorerKey

            IF @@ROWCOUNT = 0 
            BEGIN
               SELECT TOP 1 @cSKU = SKU 
               FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(IX_SKU_RetailSKU)) 
               WHERE RetailSku = @cSKU 
               AND StorerKey = @cStorerKey

               IF @@ROWCOUNT = 0 
               BEGIN 
                  SELECT @cSKU = SKU 
                  FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(IX_SKU_ManufacturerSku)) 
                  WHERE ManufacturerSku = @cSKU 
                     AND StorerKey = @cStorerKey

                  IF @@ROWCOUNT = 0 
                  BEGIN
                     --Not to hardcode ErrMsg (cc01)
                     SELECT @cLangCode=lang_code 
                     FROM rdt.RDTMOBREC (NOLOCK)
                     WHERE userName = SUSER_SNAME() 

                     SELECT @nContinue=3

                     SET @nErr = 243951
                     SET @cErrMsg = rdt.rdtgetmessage( @nErr, @cLangCode,'DSP') -- Bad Sku 
                  END
               END
            END
         END 
         ELSE
         BEGIN
            -- Get session info
            SELECT @nFunc = Func FROM rdt.rdtMobRec WITH (NOLOCK) WHERE UserName = SUSER_SNAME()

            /*
            Need a config (especially for UOM) as UPC.UOM already contain many data (before this feature) and it is not piece UOM.
            The config will help prevent piece scan module from auto retrieve, say previously piece, and now suddenly become carton QTY 
            */
            IF rdt.RDTGetConfig( @nFunc, 'GetUPCQTY', @cStorerKey) = '1'
            BEGIN
               -- 1. Return UPC.QTY
               IF @nQTY > 0
                  SET @nUPCQTY = @nQTY
               
               -- 2. Return pack UOM QTY
               ELSE IF @cUOM <> ''
                  SELECT @nUPCQTY =
                     CASE
                        WHEN @cUOM = PackUOM1 THEN Pack.CaseCnt
                        WHEN @cUOM = PackUOM2 THEN Pack.InnerPack
                        WHEN @cUOM = PackUOM3 THEN Pack.QTY
                        WHEN @cUOM = PackUOM4 THEN Pack.Pallet
                        WHEN @cUOM = PackUOM5 THEN Pack.Cube
                        WHEN @cUOM = PackUOM6 THEN Pack.GrossWgt
                        WHEN @cUOM = PackUOM7 THEN Pack.NetWgt
                        WHEN @cUOM = PackUOM8 THEN Pack.OtherUnit1
                        WHEN @cUOM = PackUOM9 THEN Pack.OtherUnit2
                        ELSE 0 
                     END
                  FROM dbo.SKU WITH (NOLOCK)
                     JOIN dbo.Pack WITH (NOLOCK) ON (Pack.PackKey = SKU.PackKey)
                  WHERE SKU.StorerKey = @cStorerKey
                     AND SKU.SKU = @cSKU   
            END
         END
      END
   END
   ELSE
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(PKSKU)) 
                     WHERE StorerKey = @cStorerKey 
                     AND   Sku = @cSKU 
                     AND   SkuStatus = @cSKUStatus)
      BEGIN
         SELECT TOP 1 @cSKU = SKU 
         FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(IX_SKU_AltSku)) 
         WHERE AltSku = @cSKU 
         AND   StorerKey = @cStorerKey
         AND   SkuStatus = @cSKUStatus

         IF @@ROWCOUNT = 0 
         BEGIN
            SELECT TOP 1 @cSKU = SKU 
            FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(IX_SKU_RetailSKU)) 
            WHERE RetailSku = @cSKU 
            AND   StorerKey = @cStorerKey
            AND   SkuStatus = @cSKUStatus

            IF @@ROWCOUNT = 0 
            BEGIN 
               SELECT @cSKU = SKU 
               FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(IX_SKU_ManufacturerSku)) 
                WHERE ManufacturerSku = @cSKU 
               AND   StorerKey = @cStorerKey
               AND   SkuStatus = @cSKUStatus

               IF @@ROWCOUNT = 0 
               BEGIN
                  SELECT TOP 1 
                     @cSKU = UPC.SKU, 
                     @cUOM = UPC.UOM, 
                     @nQTY = ISNULL( UPC.QTY, 0)
                  FROM dbo.UPC UPC WITH (NOLOCK) 
                  WHERE UPC = @cSKU 
                  AND   StorerKey = @cStorerKey  
                              
                  IF @@ROWCOUNT = 0 
                  BEGIN
                  	--Not to hardcode ErrMsg (cc01)
                  	SELECT @cLangCode=lang_code 
                  	FROM rdt.RDTMOBREC (NOLOCK)
                  	WHERE userName = SUSER_SNAME() 
                  	
                     SELECT @nContinue=3
                     
                     SET @nErr = 243952
                     SET @cErrMsg = rdt.rdtgetmessage( @nErr, @cLangCode,'DSP') -- Bad Sku
                  END 
                  ELSE
                  BEGIN
                     -- Get session info
                     SELECT @nFunc = Func FROM rdt.rdtMobRec WITH (NOLOCK) WHERE UserName = SUSER_SNAME()

                     /*
                     Need a config (especially for UOM) as UPC.UOM already contain many data (before this feature) and it is not piece UOM.
                     The config will help prevent piece scan module from auto retrieve, say previously piece, and now suddenly become carton QTY 
                     */
                     IF rdt.RDTGetConfig( @nFunc, 'GetUPCQTY', @cStorerKey) = '1'
                     BEGIN
                        IF @nQTY > 0
                           SET @nUPCQTY = @nQTY
                        ELSE
                           -- Retrieve QTY base on pack UOM
                           SELECT @nUPCQTY =
                              CASE
                                 WHEN @cUOM = PackUOM1 THEN Pack.CaseCnt
                                 WHEN @cUOM = PackUOM2 THEN Pack.InnerPack
                                 WHEN @cUOM = PackUOM3 THEN Pack.QTY
                                 WHEN @cUOM = PackUOM4 THEN Pack.Pallet
                                 WHEN @cUOM = PackUOM5 THEN Pack.Cube
                                 WHEN @cUOM = PackUOM6 THEN Pack.GrossWgt
                                 WHEN @cUOM = PackUOM7 THEN Pack.NetWgt
                                 WHEN @cUOM = PackUOM8 THEN Pack.OtherUnit1
                                 WHEN @cUOM = PackUOM9 THEN Pack.OtherUnit2
                                 ELSE 0 
                              END
                           FROM dbo.SKU WITH (NOLOCK)
                              JOIN dbo.Pack WITH (NOLOCK) ON (Pack.PackKey = SKU.PackKey)
                           WHERE SKU.StorerKey = @cStorerKey
                              AND SKU.SKU = @cSKU   
                     END
                  END
               END
            END 
         END
      END
   END

   IF @nContinue = 3
   BEGIN
      SELECT @bSuccess = 0
      SET @cSKU = '' -- (Vicky01)
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdt_GETSKU_HILLSHK TO NSQL
GO