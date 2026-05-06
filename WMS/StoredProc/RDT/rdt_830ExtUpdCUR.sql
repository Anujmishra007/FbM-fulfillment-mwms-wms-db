SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/    
/* Store procedure: [rdt_830ExtUpdCUR]                                  */    
/*                                                                      */    
/* Copyright      : Maersk                                              */    
/*                                                                      */    
/* Purpose: Decode for PMI case                                         */    
/*                                                                      */    
/* Date        Author   Ver.  Purposes                                  */    
/* 2025-09-15  TTW017   1.0   RITM8201355 - Update MBOL Header          */    
/************************************************************************/    
    
CREATE OR ALTER PROC [RDT].[rdt_830ExtUpdCUR] (    
   @nMobile       INT,    
   @nFunc         INT,    
   @cLangCode     NVARCHAR( 3),    
   @nStep         INT,    
   @nAfterStep    INT,    
   @nInputKey     INT,    
   @cFacility     NVARCHAR( 5),    
   @cStorerKey    NVARCHAR( 15),    
   @cPickSlipNo   NVARCHAR( 10),    
   @cPickZone     NVARCHAR( 10),    
   @cSuggLOC      NVARCHAR( 10),    
   @cLOC          NVARCHAR( 10),    
   @cDropID       NVARCHAR( 20),    
   @cSKU          NVARCHAR( 20),    
   @cLottable01   NVARCHAR( 18),    
   @cLottable02   NVARCHAR( 18),    
   @cLottable03   NVARCHAR( 18),    
   @dLottable04   DATETIME,    
   @dLottable05   DATETIME,    
   @cLottable06   NVARCHAR( 30),    
   @cLottable07   NVARCHAR( 30),    
   @cLottable08   NVARCHAR( 30),    
   @cLottable09   NVARCHAR( 30),    
   @cLottable10   NVARCHAR( 30),    
   @cLottable11   NVARCHAR( 30),    
   @cLottable12   NVARCHAR( 30),    
   @dLottable13   DATETIME,    
   @dLottable14   DATETIME,    
   @dLottable15   DATETIME,    
   @cUserDefine01 NVARCHAR(30),    
   @nTaskQTY      INT,    
   @nQTY          INT,    
   @cToLOC        NVARCHAR( 10),    
   @cOption       NVARCHAR( 1),    
   @nErrNo        INT           OUTPUT,    
   @cErrMsg       NVARCHAR( 20) OUTPUT    
) AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF  
  
   DECLARE @cMBOLKey         NVARCHAR(10) = '' 
         , @cOrderKey        NVARCHAR(10) = '' 
         , @cPlaceOfLoading  NVARCHAR(30) = '' 
         , @cOtherReference  NVARCHAR(30) = ''
  
   IF @nFunc = 830  
   BEGIN  
      IF @nStep = 5    
      BEGIN    
         SELECT @cOrderKey = Orderkey  
         FROM dbo.PickHeader WITH(NOLOCK)
         WHERE PickHeaderKey = @cPickSlipNo 

         IF ISNULL(@cOrderKey,'') = ''
         BEGIN
            SET @nErrNo = 65905
            SET @cErrMsg = rdt.rdtgetmessage( 65905, @cLangCode, 'DSP') --Bad OrderKey
            GOTO Quit 
         END

         SELECT @cMBOLKey        = MH.MBOLKey  
              , @cPlaceOfLoading = MH.PlaceOfLoading  
              , @cOtherReference = MH.OtherReference  
         FROM dbo.MBOL       MH WITH(NOLOCK)
         JOIN dbo.MBOLDETAIL MD WITH(NOLOCK) ON MH.MBOLKey = MD.MBOLKey
         WHERE MD.Orderkey = @cOrderkey
  
         IF ISNULL(@cPlaceOfLoading,'') = '' OR ISNULL(@cOtherReference,'') = ''
         BEGIN    
            UPDATE MH WITH(ROWLOCK)
            SET PlaceOfLoading = CASE WHEN ISNULL(MH.PlaceOfLoading,'')='' THEN CLK.UDF01 ELSE MH.PlaceOfLoading END
              , OtherReference = CASE WHEN ISNULL(MH.OtherReference,'')='' THEN CLK.UDF02 ELSE MH.OtherReference END
            FROM dbo.MBOL       MH
            JOIN dbo.MBOLDETAIL MD WITH(NOLOCK) ON MH.MBOLKey = MD.MBOLKey
            JOIN dbo.Orders     OH WITH(NOLOCK) ON MD.Orderkey = OH.Orderkey
            JOIN dbo.Codelkup  CLK WITH(NOLOCK) ON OH.Storerkey = CLK.Storerkey AND CLK.Listname = 'MBOLS2DUPD' AND CLK.Code = 'SCAN2DOOR'  
            WHERE MH.MBOLKey = @cMBOLKey  
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

GRANT EXECUTE ON RDT.rdt_830ExtUpdCUR TO NSQL
GO