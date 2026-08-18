SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_898UCCExtVal13                                  */
/* Copyright      : MAERSK                                              */
/*                                                                      */
/* copied from rdt_898UCCExtVal03, for CSC storer CFS project           */
/*                                                                      */
/* Date       Rev  Author  Purposes                                     */
/* 2026-05-25 1.0  NYE018   FCR-11903 Created                           */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_898UCCExtVal13
    @nMobile     INT  
   ,@nFunc       INT  
   ,@cLangCode   NVARCHAR(  3)  
   ,@cReceiptKey NVARCHAR( 10)  
   ,@cPOKey      NVARCHAR( 10)  
   ,@cLOC        NVARCHAR( 10)  
   ,@cToID       NVARCHAR( 18)  
   ,@cLottable01 NVARCHAR( 18)  
   ,@cLottable02 NVARCHAR( 18)  
   ,@cLottable03 NVARCHAR( 18)  
   ,@dLottable04 DATETIME  
   ,@cUCC        NVARCHAR( 20)  
   ,@nErrNo      INT           OUTPUT  
   ,@cErrMsg     NVARCHAR( 20) OUTPUT  
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   IF @nFunc = 898 -- UCC receiving
   BEGIN
      DECLARE @cStorerKey   NVARCHAR(15)
      DECLARE @cProcessType NVARCHAR(20)
      DECLARE @nUCCExists   INT

      -- Get StorerKey and ProcessType from Receipt
      SELECT @cStorerKey = StorerKey,
             @cProcessType = ISNULL(RTRIM(ProcessType), '')
      FROM dbo.Receipt WITH (NOLOCK)
      WHERE ReceiptKey = @cReceiptKey

      -- Check if UCC exists
      SET @nUCCExists = 0
      IF EXISTS (SELECT 1 FROM dbo.UCC WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND UCCNo = @cUCC)
         SET @nUCCExists = 1

      -- ProcessType 'N' (NORMAL): Only allow NEW UCCs
      IF UPPER(@cProcessType) = 'N'
      BEGIN
         IF @nUCCExists = 1
         BEGIN
            SET @nErrNo = 267501
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 267501^UCC Exists!
            GOTO Quit
         END
      END

      -- ProcessType 'C' (CID): Only allow EXISTING UCCs
      IF UPPER(@cProcessType) = 'C'
      BEGIN
         IF @nUCCExists = 0
         BEGIN
            SET @nErrNo = 267502
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- 267502^UCC Not Found
            GOTO Quit
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
GRANT EXECUTE ON rdt.rdt_898UCCExtVal13 TO NSQL
GO