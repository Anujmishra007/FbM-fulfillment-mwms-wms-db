IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_1831ExtInfo02]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_1831ExtInfo02]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/
/* Store procedure: rdt_1831ExtInfo02                                         */
/* Purpose: Display total scanned loadkey on the screen                       */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date        Rev  Author   Purposes                                         */
/* 2021-12-13  1.0  yeekung   WMS18493 Created                                */
/******************************************************************************/

CREATE PROC rdt.rdt_1831ExtInfo02 (
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cParam1          NVARCHAR( 20),
   @cParam2          NVARCHAR( 20),
   @cParam3          NVARCHAR( 20),
   @cParam4          NVARCHAR( 20),
   @cParam5          NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),  
   @nQty             INT,            
   @cLabelNo         NVARCHAR( 20),  
   @cExtendedInfo1   NVARCHAR( 20) OUTPUT,  
   @cExtendedInfo2   NVARCHAR( 20) OUTPUT
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF

   DECLARE @nCount         INT,
           @nQty2Pick      INT,
           @nQtyPicked     INT,
           @nTtl_PickQty   INT,
           @nTtl_PickedQty INT,
           @cUserName      NVARCHAR( 18),
           @cLoadKey       NVARCHAR( 10),
           @cuserdefine02  NVARCHAR( 20)
          

  
   SELECT @cUserName = UserName 
   FROM RDT.RDTMobRec WITH (NOLOCK) 
   WHERE MOBILE = @nMobile

   IF @nStep IN (2, 3)
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SELECT @cLoadKey = LoadKey
         FROM rdt.rdtSortAndPackLog WITH (NOLOCK) 
         WHERE UserName = @cUserName
         AND   Status = '1'
         AND   SKU = @cSKU

         SELECT @cuserdefine02 = lpd.UserDefine02
         FROM  dbo.LoadPlan LPD WITH (NOLOCK) 
         WHERE LPD.LoadKey = @cLoadKey


         SET @cExtendedInfo1 = 'LoadKey: ' + @cLoadKey
         SET @cExtendedInfo2 = 'Sort Lane: ' + @cuserdefine02
      END
   END

Quit:


GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_1831ExtInfo02 TO NSQL
GO

