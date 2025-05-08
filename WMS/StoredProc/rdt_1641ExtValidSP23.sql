SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1641ExtValidSP23                                */
/* Copyright: Maersk                                                    */
/* Purpose: - Royal Enfield - Traceability                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author     Purposes                                */
/* 2025-03-19 V1.0.0 ABS060     FCR-3537 Created by CE                  */
/************************************************************************/

Create OR ALTER PROC [RDT].[rdt_1641ExtValidSP23] (
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
   @cUCCOrderKey    NVARCHAR(10),
   @cDropIDOrderKey    NVARCHAR(10)

IF @nFunc = 1641
BEGIN
   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF EXISTS(SELECT 1 FROM dbo.Dropid WITH(NOLOCK) WHERE Dropid = @cDropID)
         BEGIN
            IF EXISTS(SELECT 1 FROM dbo.DropidDetail WITH(NOLOCK) WHERE Dropid = @cDropID)
            BEGIN
               SELECT @cUCCOrderKey = Orderkey 
               FROM dbo.packheader ph WITH(NOLOCK)
               JOIN dbo.packdetail pd WITH(NOLOCK) 
                  ON ph.pickslipno=pd.pickslipno 
               WHERE ph.StorerKey = @cStorerKey 
                  AND pd.DropID = @cUCCNo
                  
               SELECT @cDropIDOrderKey = Orderkey 
               FROM dbo.packheader ph WITH(NOLOCK)
               JOIN dbo.packdetail pd WITH(NOLOCK) 
                  ON ph.pickslipno=pd.pickslipno
               INNER JOIN dbo.DropIDDetail did WITH (NOLOCK) 
                  ON  did.ChildID = pd.DropID
               WHERE did.Dropid = @cDropID
               
               IF @cUCCOrderKey <> @cDropIDOrderKey
               BEGIN
                  SET @nErrNo = 70293
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Do not mix OrderKey
                  GOTO QUIT
               END
            END
         END
      END --inputkey = 1
   END --step3
END

QUIT:

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_1641ExtValidSP23 TO NSQL
GO
