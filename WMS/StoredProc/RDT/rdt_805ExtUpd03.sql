SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_805ExtUpd03                                           */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date         Rev    Author     Purposes                                    */
/* 2025-03-24   1.0.0  Dennis     FCR-2636   . Created                        */
/******************************************************************************/
CREATE OR ALTER PROC rdt.rdt_805ExtUpd03(
   @nMobile    INT,
   @nFunc      INT,
   @cLangCode  NVARCHAR( 3),
   @nStep      INT,
   @nInputKey  INT,
   @cFacility  NVARCHAR( 5),
   @cStorerKey NVARCHAR( 15),
   @cStation1  NVARCHAR( 10),
   @cStation2  NVARCHAR( 10),
   @cStation3  NVARCHAR( 10),
   @cStation4  NVARCHAR( 10),
   @cStation5  NVARCHAR( 10),
   @cMethod    NVARCHAR( 10),
   @cScanID    NVARCHAR( 20),
   @cSKU       NVARCHAR( 20),
   @nQTY       INT,
   @cCartonID    NVARCHAR( 20),
   @nActQTY    INT,
   @cNewCartonID NVARCHAR( 20),
   @cLight     NVARCHAR( 1), 
   @nErrNo     INT            OUTPUT,
   @cErrMsg    NVARCHAR( 20)  OUTPUT 
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @nCurStep       INT
   DECLARE @nUCCQty        INT
   DECLARE @nPackQTY       INT
   DECLARE @nResidualQty   INT
   DECLARE @cUCC           NVARCHAR( 20)
   DECLARE @cErrMsg1       NVARCHAR( 20)
   DECLARE @cReuseDropID   NVARCHAR(1)
   DECLARE @cPalletID      NVARCHAR( 20)

   SET @cReuseDropID = rdt.RDTGetConfig( @nFunc, 'ReuseDropID', @cStorerkey)

   SELECT @nCurStep = Step, 
          @cUCC = V_String7
   FROM rdt.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile
   
   SET @nErrNo = 0
                  
   IF @nStep = 3 AND @nCurStep = 4
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @cReuseDropID = '1'
         BEGIN
            IF NOT EXISTS(SELECT 1 FROM DBO.PICKDETAIL (NOLOCK) WHERE DROPID = @cScanID AND STATUS < '5' AND STATUS <> '4')
            BEGIN
               SELECT @cPalletID = DROPID FROM DBO.DROPIDDETAIL WITH (NOLOCK) WHERE CHILDID = @cScanID
               DELETE FROM DBO.DROPIDDETAIL WITH (ROWLOCK) WHERE CHILDID = @cScanID
               IF NOT EXISTS (SELECT 1 FROM dbo.DROPIDDETAIL WITH(NOLOCK) WHERE DROPID = @cPalletID)
                  DELETE FROM DBO.DROPID WITH (ROWLOCK) WHERE DROPID = @cPalletID
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

GRANT EXECUTE ON [rdt].[rdt_805ExtUpd03] TO NSQL
GO               
