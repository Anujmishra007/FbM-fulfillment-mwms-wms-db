if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_1580RcvFilter11]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_1580RcvFilter11]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_1580RcvFilter11                                 */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: ReceiptDetail sort order                                    */
/*                                                                      */
/* Called from:                                                         */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2020-04-01   1.0  YeeKung     WMS15666. Created                      */  
/************************************************************************/

CREATE PROCEDURE [RDT].[rdt_1580RcvFilter11]
    @nMobile     INT              
   ,@nFunc       INT              
   ,@cLangCode   NVARCHAR(  3)   
   ,@cReceiptKey NVARCHAR( 10)   
   ,@cPOKey      NVARCHAR( 10)   
   ,@cToLOC      NVARCHAR( 10)   
   ,@cToID       NVARCHAR( 18)   
   ,@cSKU        NVARCHAR( 20)   
   ,@cUCC        NVARCHAR( 20)   
   ,@nQTY        INT             
   ,@cLottable01 NVARCHAR( 18)   
   ,@cLottable02 NVARCHAR( 18)   
   ,@cLottable03 NVARCHAR( 18)   
   ,@dLottable04 DATETIME        
   ,@dLottable05 DATETIME        
   ,@cLottable06 NVARCHAR( 30)   
   ,@cLottable07 NVARCHAR( 30)   
   ,@cLottable08 NVARCHAR( 30)   
   ,@cLottable09 NVARCHAR( 30)   
   ,@cLottable10 NVARCHAR( 30)   
   ,@cLottable11 NVARCHAR( 30)   
   ,@cLottable12 NVARCHAR( 30)   
   ,@dLottable13 DATETIME        
   ,@dLottable14 DATETIME        
   ,@dLottable15 DATETIME        
   ,@cCustomSQL  NVARCHAR( MAX) OUTPUT 
   ,@nErrNo      INT            OUTPUT 
   ,@cErrMsg     NVARCHAR( 20)  OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cExternReceiptKey NVARCHAR(20)
   DECLARE @cExternLineNo NVARCHAR(20)
   
   SET @cExternReceiptKey = ''
   SET @cExternLineNo = ''
   
   SELECT 1
   FROM ReceiptDetail WITH (NOLOCK)
   WHERE ReceiptKey = @cReceiptKey
      AND SKU = @cSKU
      AND ExternReceiptKey <> ''
      AND ExternLineNo <> ''
      AND toid=@cToID
   ORDER BY ExternReceiptKey, receiptlinenumber
   
   IF @@ROWCOUNT<>0
   BEGIN
      SET @cCustomSQL = @cCustomSQL + 
         '     AND toid = ''' + @cToID + ''''    
   END

QUIT:
END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1580RcvFilter11 TO NSQL
GO
