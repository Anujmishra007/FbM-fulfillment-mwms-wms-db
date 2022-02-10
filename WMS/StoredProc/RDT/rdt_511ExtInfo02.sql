if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_511ExtInfo02') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_511ExtInfo02
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/************************************************************************/  
/* Store procedure: rdt_511ExtInfo02                                    */  
/* Purpose: Move By ID Extended Validate                                */  
/*                                                                      */  
/* Called from: rdtfnc_Move_ID                                          */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date        Rev  Author     Purposes                                 */  
/* 02-04-2020  1.0  YeeKung    WMS12738 - Created                        */  
/************************************************************************/  
  
CREATE PROC rdt.rdt_511ExtInfo02 (  
   @nMobile          INT,  
   @nFunc            INT,   
   @cLangCode        NVARCHAR( 3),   
   @nStep            INT,   
   @nInputKey        INT,   
   @cStorerKey       NVARCHAR( 15),  
   @cFromID          NVARCHAR( 18),      
   @cFromLOC         NVARCHAR( 10),  
   @cToLOC           NVARCHAR( 10),  
   @cToID            NVARCHAR( 18),  
   @cSKU             NVARCHAR( 20),  
   @cExtendedInfo    NVARCHAR( 20) OUTPUT  
)  
AS  
  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF    
  
   DECLARE @cSUSR3 NVARCHAR(20)  
  
   IF @nStep IN ( 2, 3)  
   BEGIN  
      IF @nInputKey = 1  
      BEGIN  
         SELECT @cSUSR3=SUSR3  
         FROM SKU (NOLOCK)   
         WHERE SKU=@cSKU  
         AND Storerkey=@cStorerkey  
         AND SUSR3<>''  
  
          
         SET @cExtendedInfo = @cSUSR3  
      END  
   END  
  
QUIT:  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_511ExtInfo02 TO NSQL
GO
