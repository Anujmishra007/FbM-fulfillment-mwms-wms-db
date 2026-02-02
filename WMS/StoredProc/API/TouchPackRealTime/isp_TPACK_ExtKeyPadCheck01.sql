SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

    
/*********************************************************************************/      
/* Store procedure: isp_TPACK_ExtKeyPadCheck01                                   */      
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Customize the order which need show keypad or not            */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-04   1.0  GCH225     Created                                          */
/*********************************************************************************/      
      
CREATE OR ALTER PROC [API].[isp_TPACK_ExtKeyPadCheck01] (      
     @cType             NVARCHAR(30)      = ''
   , @bIsDiscrete       BIT               = 0
   , @bIsCustom         BIT               = 0
   , @cPickSlipNo       NVARCHAR(10)      = ''
   , @cOrderKey         NVARCHAR(10)      = ''
   , @cLoadKey          NVARCHAR(10)      = ''
   , @cDropID           NVARCHAR(20)      = ''
   , @cStorerKey        NVARCHAR(15)      = ''
   , @cFacility         NVARCHAR(5)       = ''
   , @cConfigVal        NVARCHAR( 1)      = '0' OUTPUT
   , @b_Success         INT               = 1   OUTPUT
   , @n_ErrNo           INT               = 0   OUTPUT
   , @c_ErrMsg          NVARCHAR( 255)    = ''  OUTPUT
)      
AS    
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE @cMarketSegment  NVARCHAR(20)

   SET @b_Success = 1

   SELECT  @cMarketSegment = s.MarketSegment 
   FROM STORER s (NOLOCK)
   WHERE EXISTS(  SELECT 1 
                  FROM ORDERS o (NOLOCK)
                  WHERE EXISTS ( SELECT 1 
                                 FROM PICKHEADER p (NOLOCK)
                                 WHERE p.OrderKey = o.OrderKey
                                 AND p.PickHeaderKey =  @cPickslipNo
                                 )
                  AND o.StorerKey = @cStorerKey 
                  AND o.ConsigneeKey = s.StorerKey
               )        

   SET @cConfigVal = '1'

   IF EXISTS ( SELECT 1
               FROM CODELKUP (NOLOCK)
               WHERE ListName = 'CosignType'
                  AND UDF01 = @cMarketSegment 
                  AND StorerKey = @cStorerKey )
   BEGIN
      SET @cConfigVal = '0'
   END
END

