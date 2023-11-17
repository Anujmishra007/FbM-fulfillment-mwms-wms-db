
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_514DecodeSP01                                         */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Decode 2D UCC barcode                                             */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 2023-06-13  1.0  Ung      WMS-22742 Created                                */
/******************************************************************************/

CREATE OR ALTER PROC rdt.rdt_514DecodeSP01 (
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cToID          NVARCHAR( 18),
   @cToLoc         NVARCHAR( 10),
   @cFromLoc       NVARCHAR( 10),
   @cFromID        NVARCHAR( 18),
   @cBarcode       NVARCHAR( MAX),
   @cUCC           NVARCHAR( 20) OUTPUT,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   SET @nErrNo = 0
   SET @cErrMsg = ''

   /*
      2D barcode:
         ,950-8700-30:1000193193.04/06/2023;BVTN>D1^GKF001%10109975<596*HTUQU1,350

      After formatted:
      ,950-8700-30
      :1000193193      -- 2nd param, Batch no
      .04/06/2023
      ;BVTN
      >D1
      ^GKF001
      %10109975
      <596             -- 8th param, Box no
      *HTUQU1
      ,350
   */


   DECLARE @cBatchNo       NVARCHAR( 18)
   DECLARE @nBatchNoStart  INT
   DECLARE @nBatchNoEnd    INT

   DECLARE @cBoxNo         NVARCHAR( 10)
   DECLARE @nBoxNoStart    INT
   DECLARE @nBoxNoEnd      INT

   SET @nBatchNoStart = CHARINDEX( ':', @cBarcode)
   SET @nBatchNoEnd = CHARINDEX( '.', @cBarcode)
   SET @nBoxNoStart = CHARINDEX( '<', @cBarcode)
   SET @nBoxNoEnd = CHARINDEX( '*', @cBarcode)

   IF @nBatchNoStart > 0 AND @nBatchNoEnd > 0 
      SET @cBatchNo = SUBSTRING( @cBarcode, @nBatchNoStart+1, @nBatchNoEnd-@nBatchNoStart-1)
      
   IF @nBoxNoStart > 0 AND @nBoxNoEnd > 0 
      SET @cBoxNo = SUBSTRING( @cBarcode, @nBoxNoStart+1, @nBoxNoEnd-@nBoxNoStart-1)
      
   IF @cBatchNo <> '' AND @cBoxNo <> ''
      SET @cUCC = @cBatchNo + '-' + @cBoxNo
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_514DecodeSP01 TO NSQL
GO

