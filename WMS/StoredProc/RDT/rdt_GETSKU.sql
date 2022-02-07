if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_GETSKU]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [RDT].[rdt_GETSKU]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: rdt.rdt_GETSKU                                      */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: SKU Code Lookup (SKU/ManufacturerSKU/RetailSKU/AltSKU       */
/*                                                                      */
/* Called from: 3                                                       */
/*    1. From PowerBuilder                                              */
/*    2. From scheduler                                                 */
/*    3. From others stored procedures or triggers                      */
/*    4. From interface program. DX, DTS                                */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author   Purposes                                   */
/* 11-Sep-2007 1.0  Shong    Created                                    */
/* 17-Oct-2008 1.2  James    SOS119371 - Bug fix (james01)              */
/* 07-Dec-2009 1.3  Vicky    Set @cSKU = '' if no row found (Vicky01)   */
/* 14-May-2013 1.4  Ung      SOS276721 Fix UPC > 20 chars (ung01)       */
/* 08-Feb-2018 1.5  James    WMS3967-Check status of SKU (james02)      */
/* 06-Dec-2019 1.6  Chermaine INC0959117 not to hardcode errMsg (cc01)  */
/* 29-Nov-2021 1.7  Ung      Perfomance tuning                          */
/************************************************************************/
CREATE PROC    [RDT].[rdt_GETSKU]
               @cStorerKey   NVARCHAR(15)
,              @cSKU         NVARCHAR(30)      OUTPUT -- (ung01)
,              @bSuccess     int               OUTPUT
,              @nErr         int               OUTPUT
,              @cErrMsg      NVARCHAR(250)     OUTPUT
,              @cSKUStatus   NVARCHAR(10) = ''

AS
BEGIN
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nContinue INT
   DECLARE @cLangCode  NVARCHAR( 3)
   
   SELECT @nContinue = 1
   SELECT @bSuccess = 1
   SELECT @nErr = 0

   IF @cSKUStatus = ''
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM  dbo.SKU SKU WITH (NOLOCK, INDEX(PKSKU)) 
                     WHERE StorerKey = @cStorerKey AND Sku = @cSKU)
      BEGIN
   --      SET @cSKU = '' (james01)

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
                  SELECT TOP 1 @cSKU = SKU 
                  FROM dbo.UPC UPC WITH (NOLOCK) 
                  WHERE UPC = @cSKU 
                    AND StorerKey = @cStorerKey            
                  IF @@ROWCOUNT = 0 
                  BEGIN 
                     --SELECT @nContinue=3
                     --SELECT @nErr=68500
                     --SELECT @cErrMsg='NSQL'+CONVERT(char(5),@nErr)+': Bad Sku (rdt_GETSKU)'
                     
                     --Not to hardcode ErrMsg (cc01)                  	
                  	SELECT @cLangCode=lang_code 
                  	FROM rdt.RDTMOBREC (NOLOCK)
                  	WHERE userName = SUSER_SNAME() 
                  	
                     SELECT @nContinue=3        
                                  
                     SET @nErr = 68500
                     SET @cErrMsg = rdt.rdtgetmessage( @nErr, @cLangCode,'DSP') -- Bad Sku 
                  END 
               END
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
                  SELECT TOP 1 @cSKU = SKU 
                  FROM dbo.UPC UPC WITH (NOLOCK) 
                  WHERE UPC = @cSKU 
                  AND   StorerKey = @cStorerKey  
                              
                  IF @@ROWCOUNT = 0 
                  BEGIN 
                  	--SELECT @nContinue=3
                     --SELECT @nErr=68500
                     --SELECT @cErrMsg='NSQL'+CONVERT(char(5),@nErr)+': Bad Sku (rdt_GETSKU)'
                     
                  	--Not to hardcode ErrMsg (cc01)              	
                  	SELECT @cLangCode=lang_code 
                  	FROM rdt.RDTMOBREC (NOLOCK)
                  	WHERE userName = SUSER_SNAME() 
                  	
                     SELECT @nContinue=3
                     
                     SET @nErr = 68500
                     SET @cErrMsg = rdt.rdtgetmessage( @nErr, @cLangCode,'DSP') -- Bad Sku         
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

GRANT EXECUTE ON RDT.rdt_GETSKU TO NSQL
GO