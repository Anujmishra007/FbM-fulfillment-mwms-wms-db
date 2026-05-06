SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1855DisableQTY02                                */
/* Copyright      : Maersk                                              */
/* Customer       : VIVOBAREFOOT                                        */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-03-05   NickT     1.0   FCR-10824 Created                       */
/************************************************************************/
    
CREATE OR ALTER PROCEDURE rdt.rdt_1855DisableQTY02
   @nMobile                INT,
   @nFunc                  INT,
   @cLangCode              NVARCHAR( 3),
   @nStep                  INT,
   @nInputKey              INT,
   @cTaskdetailKey         NVARCHAR( 10),
   @tVarDisableQTYField    VARIABLETABLE READONLY,
   @cDisableQTYField       NVARCHAR( 1)  OUTPUT,
   @nErrNo                 INT           OUTPUT,
   @cErrMsg                NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
      @cMethod                NVARCHAR( 5)

   -- TM Assisted Cluster Pick
   IF @nFunc = 1855
   BEGIN
      -- Enable by default
      SET @cDisableQTYField = '0'

      SELECT 
         @cMethod             = V_String25
      FROM RDT.RDTMOBREC WITH (NOLOCK)
      WHERE Mobile = @nMobile

      SET @cDisableQTYField = IIF (@cMethod <> '1', '1', '0')
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1855DisableQTY02 to nSQL
GO 