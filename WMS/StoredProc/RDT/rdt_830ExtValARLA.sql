
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************/
/* Stored Procedure: rdt_830ExtValARLA                                       */
/* Creation Date: 01-04-2026                                                 */
/* Copyright: MAERSK                                                         */
/* Written by: KMS043                                                        */
/*                                                                           */
/* Purpose : Validation of DropID during Picking by 830 Function UWP-59502   */
/*                                                                           */
/* Called By:  rdt_830ExtValARLA                                             */
/*                                                                           */
/* PVCS Version: 1.0                                                         */
/*                                                                           */
/* Version: 1.0                                                              */
/*                                                                           */
/* Data Modifications:                                                       */
/*                                                                           */
/* Updates:                                                                  */
/* Date         Author   Ver  Purpose                                        */
/* 01-04-2026   KMS043,SYO054   1.0  Initial version created                 */
/*****************************************************************************/

CREATE OR ALTER   PROCEDURE [RDT].[rdt_830ExtValARLA]
   @nMobile       INT,           
   @nFunc         INT,           
   @cLangCode     NVARCHAR( 3),  
   @nStep         INT,           
   @nInputKey     INT,           
   @cFacility     NVARCHAR( 5),  
   @cStorerKey    NVARCHAR( 15), 
   @cPickSlipNo   NVARCHAR( 10), 
   @cPickZone     NVARCHAR( 10),
   @cSuggLOC      NVARCHAR( 10), 
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
   @nErrNo        INT           OUTPUT,
   @cErrMsg       NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
      
   IF @nFunc = 830 -- PickSKU
   BEGIN
      IF @nStep = 2 
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF RTRIM(LTRIM(@cDropID)) = ''
            BEGIN
               SET @nErrNo = 217931
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropIDNeeded
            END
         END
      END
   END
   
Quit:
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_830ExtValARLA] TO NSQL 
GO   

