
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_1663DefCtnType01                                      */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Date       Rev  Author   Purposes                                          */ 
/* 2023-06-21 1.0  Ung      WMS-22424 Created                                 */
/* 2023-07-14 1.1  James    WMS-23121 Extend TrackingNo to 40 chars (james01) */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1663DefCtnType01](  
   @nMobile             INT,  
   @nFunc               INT,  
   @cLangCode           NVARCHAR( 3),  
   @nStep               INT,  
   @nInputKey           INT,  
   @cFacility           NVARCHAR( 5),  
   @cStorerKey          NVARCHAR( 15),  
   @cPalletKey          NVARCHAR( 20),   
   @cPalletLOC          NVARCHAR( 10),   
   @cMBOLKey            NVARCHAR( 10),   
   @cTrackNo            NVARCHAR( 40),   
   @cOrderKey           NVARCHAR( 10),   
   @cShipperKey         NVARCHAR( 15),    
   @cWeight             NVARCHAR( 10),   
   @cOption             NVARCHAR( 1),    
   @cDefaultCartonType  NVARCHAR( 10) OUTPUT,    
   @nErrNo              INT           OUTPUT,  
   @cErrMsg             NVARCHAR( 20) OUTPUT  
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   IF @nFunc = 1663 -- TrackNoToPallet  
   BEGIN
      IF EXISTS( SELECT 1
         FROM dbo.Orders WITH (NOLOCK)
         WHERE OrderKey = @cOrderKey
            AND ECOM_PRESALE_FLAG = 'PR')

         SET @cDefaultCartonType = '*P03*'
   END  
  
Quit:  
  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1663DefCtnType01 TO NSQL
GO