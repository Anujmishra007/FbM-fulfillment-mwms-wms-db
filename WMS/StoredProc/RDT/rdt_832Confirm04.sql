
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_832Confirm04                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: full carton pack                                            */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* 2025-09-19   1.0  Cuize   FCR-7763                                   */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_832Confirm04] (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFacility        NVARCHAR( 5), 
   @cType            NVARCHAR( 10), --CHECK/CONFIRM
   @tConfirm         VariableTable READONLY, 
   @cDoc1Value       NVARCHAR( 20),
   @cCartonID        NVARCHAR( 20),
   @cCartonSKU       NVARCHAR( 20),
   @nCartonQTY       INT, 
   @cPackInfo        NVARCHAR( 4)  = '', 
   @cCartonType      NVARCHAR( 10) = '',
   @fCube            FLOAT         = 0,
   @fWeight          FLOAT         = 0,
   @cPackInfoRefNo   NVARCHAR( 20) = '',
   @cPickSlipNo      NVARCHAR( 10) OUTPUT,
   @nCartonNo        INT           OUTPUT,
   @cLabelNo         NVARCHAR( 20) OUTPUT,
   @cPrintPackList   NVARCHAR( 1)  OUTPUT, 
   @nErrNo           INT           OUTPUT,
   @cErrMsg          NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF



END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_832Confirm04 TO NSQL
GO
