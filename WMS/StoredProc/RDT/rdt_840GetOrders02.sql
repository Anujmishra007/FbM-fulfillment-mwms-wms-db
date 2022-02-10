IF EXISTS (SELECT name FROM sysobjects WHERE name = 'rdt_840GetOrders02' AND type = 'P')
   DROP PROC rdt.rdt_840GetOrders02
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Store procedure: rdt_840GetOrders02                                  */
/* Copyright      : LF logistics                                        */
/*                                                                      */
/* Purpose: Return orders using pickdetail.dropid                       */
/*                                                                      */
/* Modifications log:                                                   */
/* Date        Rev  Author      Purposes                                */
/* 2020-09-15  1.0  James       WMS-14322. Created                      */
/************************************************************************/

CREATE PROCEDURE rdt.rdt_840GetOrders02
   @nMobile                   INT,
   @nFunc                     INT,
   @cLangCode                 NVARCHAR( 3),
   @nStep                     INT,
   @nInputKey                 INT,
   @cStorerkey                NVARCHAR( 15),
   @cDropID                   NVARCHAR( 20),
   @tGetOrders                VariableTable READONLY,
   @cOrderKey                 NVARCHAR( 10) OUTPUT,
   @nErrNo                    INT           OUTPUT,
   @cErrMsg                   NVARCHAR( 20) OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cTempOrderKey     NVARCHAR( 10)
   DECLARE @nCnt              INT
   
   SET @cOrderKey = ''
   
   IF @nStep = 1 -- OrderKey/DropID
   BEGIN
      IF @nInputKey = 1 -- ENTER
      BEGIN
         -- Retrieve orderkey from pickdetail.dropid
         SET @cOrderKey = ''
         SELECT TOP 1 @cOrderKey = OrderKey
         FROM dbo.PICKDETAIL WITH (NOLOCK)
         WHERE Storerkey = @cStorerkey
         AND   DropID = @cDropID
         AND   [Status] = '3'
         AND   CaseID = 'Sorted'
         ORDER BY 1
      END
   END

Quit:
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON rdt.rdt_840GetOrders02 TO NSQL 
GO   


