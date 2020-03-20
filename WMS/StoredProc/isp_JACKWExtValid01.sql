if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_JACKWExtValid01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [RDT].[rdt_JACKWExtValid01]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: rdt_JACKWExtValid01                                 */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Validate Qty must be key in first before can proceed to     */
/*          verify sku                                                  */
/*                                                                      */
/* Called from: rdtfnc_PieceReceiving                                   */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2014-08-28  1.0  James       SOS315958 Created                       */  
/* 2014-11-18  1.1  CSCHONG     Added Lottables 06-15 (CS01)            */
/************************************************************************/

CREATE PROC [RDT].[rdt_JACKWExtValid01] (
   @nMobile          INT, 
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorer          NVARCHAR( 15), 
   @cReceiptKey      NVARCHAR( 10), 
   @cPOKey           NVARCHAR( 10), 
   @cLOC             NVARCHAR( 10), 
   @cToID            NVARCHAR( 18), 
   @cLottable01      NVARCHAR( 18), 
   @cLottable02      NVARCHAR( 18), 
   @cLottable03      NVARCHAR( 18), 
   @dLottable04      DATETIME,  
   @dLottable05      DATETIME,            --(CS01) 
   @cLottable06      NVARCHAR( 30),       --(CS01)
   @cLottable07      NVARCHAR( 30),       --(CS01)
   @cLottable08      NVARCHAR( 30),       --(CS01)
   @cLottable09      NVARCHAR( 30),       --(CS01)
   @cLottable10      NVARCHAR( 30),       --(CS01)
   @cLottable11      NVARCHAR( 30),       --(CS01)
   @cLottable12      NVARCHAR( 30),       --(CS01)
   @dLottable13      DATETIME,            --(CS01) 
   @dLottable14      DATETIME,            --(CS01) 
   @dLottable15      DATETIME,            --(CS01) 
   @cSKU             NVARCHAR( 20), 
   @cQty             NVARCHAR( 5), 
   @nErrNo           INT           OUTPUT, 
   @cErrMsg          NVARCHAR( 20) OUTPUT 

)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   IF @nStep = 3 AND @nInputKey = 1 AND ISNULL( @cToID, '') <> ''
   BEGIN
      IF SUBSTRING( @cToID, 1, 1) <> '1'
         SET @cErrMsg = 'ID START WITH #1'

      IF LEN( RTRIM( @cToID)) <> 4
         SET @cErrMsg = 'ID MUST BE 4 DIGITS'

      GOTO Quit
   END

   IF @nStep <> 5 OR @nInputKey <> 1
      GOTO Quit

   IF ISNULL( @cQty, '') = ''
   BEGIN
      SET @cErrMsg = 'PLS KEY IN QTY'
      GOTO Quit
   END

   IF rdt.rdtIsValidQty( @cQty, 21) = 0
   BEGIN
      SET @cErrMsg = 'INVALID QTY KEYED IN'
      GOTO Quit
   END
   
Quit:
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdt_JACKWExtValid01 TO NSQL
GO
