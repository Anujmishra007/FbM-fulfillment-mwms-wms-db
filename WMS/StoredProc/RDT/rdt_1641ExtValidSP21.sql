SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1641ExtValidSP21                                */
/* Purpose: FCR-1406 PUMA - Traceability                                */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2024-12-02 1.0.0  LJQ006     FCR-1406 Created                        */
/* 2025-03-24 1.1.0  Dennis     FCR-1406 Fix Bug                        */
/************************************************************************/

CREATE OR ALTER PROC rdt.rdt_1641ExtValidSP21 (
   @nMobile      INT,
   @nFunc        INT,
   @cLangCode    NVARCHAR(3),
   @nStep        INT,
   @nInputKey    INT, 
   @cStorerKey   NVARCHAR(15),
   @cDropID      NVARCHAR(20),
   @cUCCNo       NVARCHAR(20),
   @cPrevLoadKey NVARCHAR(10),
   @cParam1      NVARCHAR(20),
   @cParam2      NVARCHAR(20),
   @cParam3      NVARCHAR(20),
   @cParam4      NVARCHAR(20),
   @cParam5      NVARCHAR(20),
   @nErrNo       INT           OUTPUT,
   @cErrMsg      NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

DECLARE
   @cUCCWaveKey    NVARCHAR(10),
   @cDropIDWaveKey    NVARCHAR(10)

IF @nFunc = 1641
BEGIN
   IF @nStep = 3
   BEGIN
      IF EXISTS(SELECT 1 FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID)
      BEGIN
         IF EXISTS(SELECT 1 FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)
         BEGIN
            SELECT TOP 1 @cUCCWaveKey = O.UserDefine09 
            FROM dbo.PICKDETAIL pd (NOLOCK)
            INNER JOIN dbo.Orders O WITH(NOLOCK) ON O.OrderKey = pd.OrderKey
            WHERE pd.StorerKey = @cStorerKey AND pd.DropID = @cUCCNo
            ORDER BY pd.ADDDATE DESC

            SELECT TOP 1 @cDropIDWaveKey = O.UserDefine09 
            FROM dbo.PICKDETAIL pd WITH(NOLOCK)
            INNER JOIN dbo.Orders O WITH(NOLOCK) ON O.OrderKey = pd.OrderKey
            INNER JOIN dbo.DropIDDetail did WITH(NOLOCK) ON  did.ChildID = pd.DropID
            WHERE did.Dropid = @cDropID

            IF @cUCCWaveKey <> @cDropIDWaveKey
            BEGIN
               SET @nErrNo = 229952
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- WaveKey does not match
            END
         END
      END
   END
END

QUIT:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_1641ExtValidSP21 TO NSQL
GO

