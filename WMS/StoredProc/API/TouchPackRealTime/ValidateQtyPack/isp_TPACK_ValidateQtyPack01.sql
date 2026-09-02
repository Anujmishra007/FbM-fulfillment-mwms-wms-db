SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateQtyPack01                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Validate Packed Qty versus Pick Qty for Logitech             */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-18   1.0  GCH225     UWP-27781: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ValidateQtyPack01] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cInputValue1         NVARCHAR(128)     = ''
   , @cInputValue2         NVARCHAR(MAX)     = ''
   , @cInputValue3         NVARCHAR(128)     = ''
   , @cScanType            NVARCHAR(20)      = ''
   , @cSKU                 NVARCHAR(20)      = ''
   , @nCartonNo            INT               = 0
   , @nQty                 INT               = 0   OUTPUT
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

         , @cSerialNoType        NVARCHAR(1)
         , @cSerialNo            NVARCHAR(100)
         , @nCtnPerPL            INT
         , @cWavekey             NVARCHAR(10)
         , @nQtyAllocated        INT
         , @nQtyPacked           INT

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @cSerialNoType      = ''
   SET @cSerialNo          = ''
   SET @nCtnPerPL          = 0
   SET @cWavekey           = ''
   SET @nQtyAllocated      = 0
   SET @nQtyPacked         = 0

   IF ISJSON(@cInputValue2) = 1
   AND EXISTS(SELECT 1 FROM OPENJSON(@cInputValue2))
   AND EXISTS (
      SELECT 1
      FROM SKU (NOLOCK)
      WHERE Storerkey = @cStorerKey
      AND Sku = @cSKU
      AND BUSR7 = 'Yes'
   )
   BEGIN
      SELECT @cSerialNo = ISNULL([value], '')
      FROM OPENJSON(@cInputValue2)
      WITH ([value] NVARCHAR(100) '$') J

      SET @cSerialNoType = RIGHT(RTRIM(@cSerialNo),1)

      IF @cSerialNoType = 'P'
      BEGIN 
         SELECT 1
         FROM TRACKINGID TID WITH (NOLOCK)
         WHERE TID.ParentTrackingID = @cSerialNo
         AND   TID.Storerkey = @cStorerKey
         AND   TID.PickMethod <> 'loose'                
         AND   TID.[Status] >= 1 AND TID.[Status] <= 9
      
         SET @nCtnPerPL = @@ROWCOUNT

         SELECT @nQty = P.CaseCnt * @nCtnPerPL
         FROM SKU S WITH (NOLOCK)
         JOIN PACK P WITH (NOLOCK) ON S.Packkey = P.Packkey
         WHERE S.Storerkey = @cStorerKey
         AND S.Sku = @cSKU
         AND S.BUSR7 = 'Yes'
      END 

      IF @cSerialNoType = 'M'
      BEGIN 
         SELECT @nQty = PACK.CaseCnt
         FROM SKU WITH (NOLOCK)
         JOIN PACK WITH (NOLOCK) 
         ON (SKU.Packkey = PACK.Packkey)
         WHERE SKU.Storerkey = @cStorerKey
         AND   SKU.Sku = @cSKU
      END

      IF @cSerialNoType = 'C'
      BEGIN 
         SELECT @nQty = PACK.InnerPack
         FROM SKU WITH (NOLOCK)
         JOIN PACK WITH (NOLOCK) 
         ON (SKU.Packkey = PACK.Packkey)
         WHERE SKU.Storerkey = @cStorerKey
         AND   SKU.Sku = @cSKU
      END

      IF @cSerialNoType = '9'
      BEGIN 
         SET @nQty = 1
      END

      IF @cSerialNoType = 'P'
      BEGIN
         SELECT TOP 1 @cWavekey  = Wavekey  
         FROM dbo.fnc_GetWaveOrder_DropID(@cDropID);    

         SELECT @nQtyAllocated = ISNULL(SUM(PD.Qty),0)  
         FROM PICKDETAIL PD WITH (NOLOCK)  
         JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PD.Orderkey = WD.Orderkey)  
         WHERE PD.DropID = @cDropID  
         AND   WD.Wavekey= @cWavekey  
         AND   PD.Storerkey = @cStorerKey  
         AND   PD.Sku = @cSKU
          
         SELECT @nQtyPacked = ISNULL(SUM(PD.Qty),0)  
         FROM PACKHEADER PH WITH (NOLOCK)   
         JOIN PACKDETAIL PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)  
         JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PH.Orderkey = WD.Orderkey)  
         WHERE PD.DropID = @cDropID  
         AND   WD.Wavekey= @cWavekey  
         AND   PD.Storerkey = @cStorerKey  
         AND   PD.Sku = @cSKU
           
         IF @nQtyAllocated - @nQtyPacked > @nQty
         BEGIN
            SET @n_Continue = 3      
            SET @n_ErrNo = 60100                                                                                         
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Pack Qty > Pick Qty.'                                                                                                  
            GOTO EXIT_SP                                                                                        
         END
      END
      ELSE
      BEGIN
         IF (dbo.fnc_GetOrder_DropID (@cDropID, @cStorerKey, @cSKU, @nQty)) = ''
         BEGIN
            SET @n_Continue = 3                                                                                              
            SET @n_ErrNo = 60100                                                                                         
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- 'Pack Qty > Pick Qty.'                                                                                                  
            GOTO EXIT_SP
         END
      END
   END
   ELSE
   BEGIN
      EXEC [API].[isp_TPACK_ValidateQtyPack]
           @cType             = @cType            
         , @bIsDiscrete       = @bIsDiscrete      
         , @bIsCustom         = @bIsCustom        
         , @cPickSlipNo       = @cPickSlipNo       
         , @cOrderKey         = @cOrderKey         
         , @cLoadKey          = @cLoadKey          
         , @cDropID           = @cDropID  
         , @cStorerKey        = @cStorerKey        
         , @cFacility         = @cFacility  
         , @cInputValue1      = @cInputValue1
         , @cScanType         = @cScanType
         , @cSKU              = @cSKU
         , @c_UserID          = @c_UserID
         , @cLangCode         = @cLangCode
         , @nQty              = @nQty
         , @b_Success         = @b_Success   OUTPUT
         , @n_ErrNo           = @n_ErrNo     OUTPUT
         , @c_ErrMsg          = @c_ErrMsg    OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3    
         GOTO EXIT_SP
      END
   END

PROCEED:

EXIT_SP:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_ValidateQtyPack01] TO NSQL
GO