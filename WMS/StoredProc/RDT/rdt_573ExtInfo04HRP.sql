SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************/
/* Store procedure: rdt_573ExtInfo04HRP                                 */
/* Copyright      : Maersk WMS                                          */
/*                                                                      */
/* Purpose: Display total scanned UCC on pallet                         */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 2025-04-02 1.0  WSE016     WCEET-2988 Created                        */
/************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_573ExtInfo04HRP] (
   @nMobile           INT,
   @nFunc             INT,
   @cLangCode         NVARCHAR( 3),
   @nStep             INT,
   @nInputKey         INT,
   @cFacility         NVARCHAR( 5),
   @cStorerKey        NVARCHAR( 15),
   @cLoc              NVARCHAR( 10),
   @cID               NVARCHAR( 18),
   @cUCC              NVARCHAR( 20),
   @tExtInfoVar       VariableTable READONLY,
   @cExtendedInfo     NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @cCOD  NVARCHAR( 20),
        @cErrMsg NVARCHAR(20),
        @cErrMsg1 NVARCHAR(20),
        @cErrMsg2 NVARCHAR(20)



   IF @nStep IN ( 3, 4)
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         --Display COD in Step 4




		 SELECT 
		      @cCOD = CASE 
		         WHEN COUNT(DISTINCT ISNULL(RD.Lottable03, '0')) = 1 
		              AND MAX(LEN(ISNULL(RD.Lottable03, ''))) > 0 
		             THEN MAX(ISNULL(RD.Lottable03, 'NO COD'))
		         WHEN MAX(LEN(ISNULL(RD.Lottable03, ''))) = 0 
		             THEN 'NO COD'
		         ELSE 'MIXED'
		     END 
		 FROM dbo.ReceiptDetail RD WITH (NOLOCK)
		 JOIN rdt.rdtConReceiveLog CR WITH (NOLOCK) 
		     ON RD.ReceiptKey = CR.ReceiptKey
		 WHERE CR.Mobile = @nMobile
		   AND RD.BeforeReceivedQty > 0
		   AND RD.ToId = @cID
		 GROUP BY RD.ReceiptKey;



         SET @cExtendedInfo = 'COD on LPN: ' + @cCOD
        END
    END


Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_573ExtInfo04HRP TO NSQL
GO

