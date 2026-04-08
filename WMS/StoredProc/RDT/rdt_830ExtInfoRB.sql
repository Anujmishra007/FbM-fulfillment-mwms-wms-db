SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: rdt_830ExtInfoRB                                   */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 03/02/2026   PPA374  1.0   Created. Informing user about multi SKU.  */
/* 13/03/2026   OKA065  1.1   DataCapture replaced by BUSR09.           */
/************************************************************************/
CREATE OR ALTER   PROC [RDT].[rdt_830ExtInfoRB]
            @nMobile       INT,            
            @nFunc         INT,            
            @cLangCode     NVARCHAR( 3),   
            @nStep         INT,            
            @nAfterStep    INT,            
            @nInputKey     INT,            
            @cFacility     NVARCHAR( 5),   
            @cStorerKey    NVARCHAR( 15),  
            @cPickSlipNo   NVARCHAR( 10),  
            @cPickZone     NVARCHAR( 10),  
            @cSuggLOC NVARCHAR( 10),  
            @cLOC          NVARCHAR( 10),  
            @cDropID       NVARCHAR( 20),  
            @cSKU          NVARCHAR( 20),  
            @cLottable01   NVARCHAR( 18),  
            @cLottable02   NVARCHAR( 18),  
            @cLottable03   NVARCHAR( 18),  
            @dLottable04   DATETIME,       
            @dLottable05   DATETIME,       
            @cLottable06   NVARCHAR( 30),  
            @cLottable07   NVARCHAR( 30),  
            @cLottable08   NVARCHAR( 30),  
            @cLottable09   NVARCHAR( 30),  
            @cLottable10   NVARCHAR( 30),  
            @cLottable11   NVARCHAR( 30),  
            @cLottable12   NVARCHAR( 30),  
            @dLottable13   DATETIME,       
            @dLottable14   DATETIME,       
            @dLottable15   DATETIME,       
            @nTaskQTY      INT,            
            @nQTY          INT,            
            @cToLOC        NVARCHAR( 10),  
            @cOption       NVARCHAR( 1),   
            @cExtendedInfo NVARCHAR( 20) OUTPUT,  
            @nErrNo        INT           OUTPUT,  
            @cErrMsg       NVARCHAR( 20) OUTPUT  
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   DECLARE @cMultiBox NVARCHAR(5)

   SELECT TOP 1 @cMultiBox = ISNULL(BUSR9,'0') FROM dbo.SKU WITH(NOLOCK) WHERE SKU = @cSKU

   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
	     IF @cMultiBox = '1'
         BEGIN
            SET @cExtendedInfo = '!!! MULTIBOX SKU !!!'
         END
	  END
   END
   ELSE
   BEGIN
      SET @cExtendedInfo = ''
   END
   
Quit:
END


