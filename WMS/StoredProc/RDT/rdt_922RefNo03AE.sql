
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_922RefNo03AE Copy of rdt_922RefNo02             */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-03-08 1.0  ELB012     Project American Eagle                    */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_922RefNo03AE] (
   @nMobile      INT,             
   @nFunc        INT,             
   @cLangCode    NVARCHAR( 3),    
   @nStep        INT,             
   @nInputKey    INT,             
   @cFacility    NVARCHAR( 5),    
   @cStorerKey   NVARCHAR( 15),   
   @cRefNum      NVARCHAR( 30),   
   @cMbolKey     NVARCHAR( 10) OUTPUT,   
   @cLoadKey     NVARCHAR( 10) OUTPUT,   
   @cOrderKey    NVARCHAR( 10) OUTPUT,   
   @cType        NVARCHAR( 1)  OUTPUT,   
   @nErrNo       INT           OUTPUT,   
   @cErrMsg      NVARCHAR( 20) OUTPUT  
)
AS

SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

IF @nFunc = 922 -- Scan to truck
BEGIN
   -- Get mbol info

	SET @cMbolKey = NULL;

	SELECT
		@cMbolKey = MD.MbolKey
	FROM dbo.PickDetail PD WITH (NOLOCK)
	INNER JOIN dbo.MbolDetail MD WITH (NOLOCK)
		ON PD.OrderKey = MD.OrderKey
	WHERE PD.DropID = @cRefNum
	GROUP BY MD.MbolKey

	IF @@ROWCOUNT <> 1
	BEGIN
		SET @nErrNo = 276851
		SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Mbol
		GOTO Quit
	END
   
	SET @cType = 'M'

END

Quit:  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_922RefNo03AE] TO NSQL
GO
