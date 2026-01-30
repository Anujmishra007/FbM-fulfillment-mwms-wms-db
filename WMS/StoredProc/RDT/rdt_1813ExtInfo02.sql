SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Store procedure: rdt_1813ExtInfo02                                   */    
/* Copyright      : IDS                                                 */    
/*                                                                      */    
/* Purpose: Show the Doc type (B2C or B2B)                              */    
/*                                                                      */    
/* Called from: rdtfnc_PalletConsolidate                                */    
/*                                                                      */    
/* Exceed version: 5.4                                                  */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date        Rev  Author      Purposes                                */    
/* 12-12-2025  1.0  PSJ036      UWP-48147 Created                       */   
/************************************************************************/    
    
ALTER   PROCEDURE [RDT].[rdt_1813ExtInfo02]    
   @nMobile         INT,       
   @nFunc           INT,       
   @cLangCode       NVARCHAR( 3),
   @nStep           INT,       
   @nInputKey       INT,       
   @cStorerKey      NVARCHAR( 15), 
   @cFromID         NVARCHAR( 20), 
   @cOption         NVARCHAR( 1), 
   @cSKU            NVARCHAR( 20), 
   @nQty            INT, 
   @cToID           NVARCHAR( 20), 
   @c_oFieled01      NVARCHAR( 20) OUTPUT
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   DECLARE @cCongsineeKey     NVARCHAR( 15),
		   @cType             NVARCHAR( 10)

   SET @c_oFieled01 = ''
   
   IF @nInputKey = 1
   BEGIN
      IF @nStep in (1,2)
      BEGIN
         -- 1 Pallet 1 Ship To (Consignee)
         SET @cCongsineeKey = ''
		 SET @cType         = ''

         SELECT TOP 1 @cCongsineeKey = O.ConsigneeKey,
					  @cType         = O.Type
         FROM dbo.PickDetail PD WITH (NOLOCK) 
         JOIN dbo.Orders O WITH (NOLOCK) ON ( PD.OrderKey = O.OrderKey)
         WHERE PD.StorerKey = @cStorerKey 
         AND   PD.ID = @cFromID

         SET @c_oFieled01 = 'Order Type:' + @cType
      END
   END

   QUIT:

END -- End Procedure    

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1813ExtInfo02] TO [NSQL]
GO