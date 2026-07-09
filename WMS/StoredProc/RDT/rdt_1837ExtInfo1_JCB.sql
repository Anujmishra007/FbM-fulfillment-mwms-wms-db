SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Store procedure: rdt_1837ExtInfo1_JCB                                */  
/*                                                                      */  
/* Purpose:       Merging DropIDs after picking                         */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2026-01-21 1.0  TPT001     Created                                   */  
/************************************************************************/ 
CREATE OR ALTER PROC [RDT].[rdt_1837ExtInfo1_JCB] (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cCartonID      NVARCHAR( 20), 
   @cPalletID      NVARCHAR( 20), 
   @cLoadKey       NVARCHAR( 10), 
   @cLoc           NVARCHAR( 10), 
   @cOption        NVARCHAR( 1), 
   @tExtValidate   VariableTable READONLY,
   @cExtendedInfo  NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cErrMsg01        NVARCHAR( 20),
           @cErrMsg02        NVARCHAR( 20),
           @cPallet			 NVARCHAR( 20)= '',
           @cPallets		 NVARCHAR( 255) =''

   IF @nStep = 1 -- On first screen
   BEGIN
      IF @nInputKey = 1 -- Once enter is pressed
      BEGIN
         -- Display all opened pallets
         IF EXISTS (SELECT 1 FROM rdt.rdtSortLaneLocLog WITH(NOLOCK) WHERE Status=1 AND LOC LIKE 'T2PPS%')
         BEGIN
         	DECLARE Plts CURSOR LOCAL FAST_FORWARD FOR
         		SELECT DISTINCT ID FROM rdt.rdtSortLaneLocLog WITH(NOLOCK) WHERE Status=1 AND LOC LIKE 'T2PPS%';
         	OPEN Plts;
   			FETCH NEXT FROM Plts INTO @cPallet
   			WHILE @@FETCH_STATUS = 0
   				BEGIN
   				IF LEN(@cPallets)=0
   					BEGIN
   						SET @cPallets=@cPallet
   					END
   				ELSE
   					BEGIN
   						SET @cPallets = @cPallets + ', ' + @cPallet
   					END
   				FETCH NEXT FROM Plts INTO @cPallet
   				END
   			CLOSE Plts;
   			DEALLOCATE Plts;
   			
            SET @cErrMsg01 = ''
            SET @cErrMsg02 = ''

            SET @nErrNo = 0
            SET @cErrMsg01 = 'OPEN PLTs '
            SET @cErrMsg02 = @cPallets 

            EXEC rdt.rdtInsertMsgQueue @nMobile, @nErrNo OUTPUT, @cErrMsg OUTPUT, 
                 @cErrMsg01, @cErrMsg02
            SET @nErrNo = 0   -- Reset error no
            
         END
      END
   END


   Quit:

END
GO
GRANT EXECUTE ON rdt_1837ExtInfo1_JCB TO NSQL
GO
