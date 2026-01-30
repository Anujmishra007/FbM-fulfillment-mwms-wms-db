SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_Pack_SKU                                           */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Pack SKU Main Process                                        */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-05   1.0  GCH225     Created                                          */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_Pack_SKU] (
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
   , @nQty                 INT               = 0       
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @nCartonNo            INT               = 0   OUTPUT
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

   DECLARE @cRoute               NVARCHAR(10)
         , @cConsigneeKey        NVARCHAR(15)
         , @cLabelNo             NVARCHAR(20)
         , @cLabelLine           NVARCHAR(20)
         , @cCartonGroup         NVARCHAR(10)
         , @bIsINS               BIT
         , @cUCCtoUPC            NVARCHAR(10)
         , @cUCCtoDropID         NVARCHAR(10)
   
   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @cRoute             = ''
   SET @cConsigneeKey      = ''
   SET @cLabelNo           = ''
   SET @cLabelLine         = RIGHT( '00000' + CAST(1 AS NVARCHAR(5)), 5)
   SET @cCartonGroup       = ''
   SET @bIsINS             = 1
   SET @cUCCtoUPC          = ''
   SET @cUCCtoDropID       = ''

   IF @cScanType = 'ucc'
   BEGIN
      SELECT @cUCCtoUPC =Svalue 
      FROM STORERCONFIG WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey 
      AND ConfigKey = 'PACKUPD_UCCTOUPC' 

      SELECT @cUCCtoDropID =SValue 
      FROM STORERCONFIG WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey 
      AND ConfigKey = 'PACKUPD_UCCTODROPID' 
   END

   --Check PackHeader
   IF NOT EXISTS( SELECT 1 
                  FROM PACKHEADER (NOLOCK) 
                  WHERE PickslipNo = @cPickslipNo
   )  
   BEGIN
      IF @bIsDiscrete = 1 AND @bIsCustom = 0
      BEGIN
         SELECT @cRoute        = [Route]
              , @cConsigneeKey = ConsigneeKey
         FROM ORDERS (NOLOCK)
         WHERE OrderKey = @cOrderKey
      END

      SELECT @cCartonGroup   = ISNULL(RTRIM([CartonGroup]), '')
      FROM [dbo].[STORER] WITH (NOLOCK) 
      WHERE StorerKey = @cStorerKey

      INSERT INTO PACKHEADER ( PickSlipNo
                             , StorerKey
                             , [Route]
                             , OrderKey
                             , OrderRefNo
                             , LoadKey
                             , ConsigneeKey
                             , [Status]
                             , CartonGroup
                             , AddWho
                             , AddDate)
                      VALUES(  @cPickSlipNo
                             , @cStorerKey
                             , @cRoute
                             , IIF (@bIsDiscrete = 1 AND @bIsCustom = 0, @cOrderKey, '')
                             , @cLoadKey
                             , @cLoadKey
                             , @cConsigneeKey
                             , '0'
                             , @cCartonGroup
                             , @c_UserID
                             , GETDATE()
                        )
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11151
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into PackHeader.'
         GOTO EXIT_SP
      END
   END

   -- Perform Check the Qty
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

   -- @cScanType List('sku','retailsku', 'manusku', 'altsku', 'upc', 'ucc', 'serialno')
   SELECT @cLabelNo = LabelNo
   FROM PACKDETAIL (NOLOCK)
   WHERE PickSlipNo = @cPickSlipNo
   AND CartonNo = @nCartonNo

   IF @@ROWCOUNT = 0
   BEGIN
      EXEC [API].[isp_TPACK_GetPackLabelNo]
            @cType             = @cType            
         , @bIsDiscrete       = @bIsDiscrete      
         , @bIsCustom         = @bIsCustom        
         , @cPickSlipNo       = @cPickSlipNo       
         , @cOrderKey         = @cOrderKey         
         , @cLoadKey          = @cLoadKey          
         , @cDropID           = @cDropID  
         , @cStorerKey        = @cStorerKey        
         , @cFacility         = @cFacility      
         , @cLangCode         = @cLangCode
         , @nCartonNo         = @nCartonNo
         , @c_LabelNo         = @cLabelNo    OUTPUT
         , @b_Success         = @b_Success   OUTPUT
         , @n_ErrNo           = @n_ErrNo     OUTPUT
         , @c_ErrMsg          = @c_ErrMsg    OUTPUT

      IF @b_Success = 0
      BEGIN
         SET @n_Continue  = 3    
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
     
      IF @cScanType IN( 'upc', 'altsku', 'manusku', 'retailsku') 
      BEGIN
         SELECT @cLabelLine = LabelLine
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND UPC = @cInputValue1
         AND (@cInputValue3 = '' OR LOTTABLEVALUE = @cInputValue3)
      END
      ELSE IF @cInputValue3 <> ''
      BEGIN
         SELECT @cLabelLine = LabelLine
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND UPC = ''
         AND LOTTABLEVALUE = @cInputValue3
      END
      ELSE -- all other scan type
      BEGIN
         SELECT @cLabelLine = LabelLine
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND UPC = ''
         AND LOTTABLEVALUE = ''
      END

      IF @@ROWCOUNT = 1
      BEGIN
         SET @bIsINS = 0 
      END
      ELSE
      BEGIN
         SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( ISNULL( MAX( LabelLine), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo    
      END
   END

   BEGIN TRAN
   --Insert/Update PackDetail
   IF @bIsINS = 1
   BEGIN
      IF @nCartonNo = 0
      BEGIN
         SELECT TOP 1 
            @nCartonNo = MAX(CartonNo)
         FROM PACKDETAIL(NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo

         SET @nCartonNo = ISNULL(@nCartonNo, 0) + 1
      END 

      INSERT INTO PACKDETAIL( PickSlipNo
                        , CartonNo
                        , LabelNo
                        , LabelLine
                        , StorerKey
                        , SKU
                        , Qty
                        , AddWho
                        , AddDate
                        , UPC
                        , DropID
                        , LOTTABLEVALUE
                        )
               VALUES(    @cPickSlipNo
                        , @nCartonNo
                        , @cLabelNo
                        , @cLabelLine
                        , @cStorerKey
                        , @cSKU
                        , @nQty
                        , @c_UserID
                        , GETDATE()
                        , IIF(@cScanType IN ('upc', 'altsku', 'manusku', 'retailsku'), @cInputValue1
                             , IIF(@cScanType = 'ucc', IIF(@cUCCtoUPC = '1', @cInputValue1, '')
                                  , ''
                             )
                          )
                        , IIF(@cScanType = 'ucc', IIF(@cUCCtoDropID = '1', @cInputValue1, @cDropID)
                             , @cDropID
                          )
                        , @cInputValue3
                     )
      IF @@ERROR <> 0
      BEGIN
         SET @n_ErrNo = 11152
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into PackDetail.'
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      UPDATE PACKDETAIL WITH (ROWLOCK)
      SET Qty = Qty + @nQty
         , EditWho = @c_UserID
         , EditDate = GETDATE()
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND LabelNo = @cLabelNo
      AND LabelLine = @cLabelLine

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11153
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into PackDetail.'
         GOTO EXIT_SP
      END
   END

   --Insert/Update PackInfo
   IF EXISTS ( SELECT 1 
               FROM PACKINFO (NOLOCK)
               WHERE PickSlipNo = @cPickSlipNo
               AND CartonNo = @nCartonNo
   )
   BEGIN
      UPDATE PACKINFO WITH (ROWLOCK)
      SET  EditWho = @c_UserID
         , EditDate = GETDATE()
         , UCCNo = IIF(@cScanType = 'ucc', @cInputValue1, UCCNo)
         , CartonStatus = 'INPROGRESS'
         , TrafficCop = NULL
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11154
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into PackInfo.'
         GOTO EXIT_SP
      END
   END
   ELSE
   BEGIN
      INSERT INTO PACKINFO ( PickSlipNo
                           , CartonNo
                           , [Weight]
                           , [Cube]
                           , Qty
                           , AddDate
                           , AddWho
                           , EditDate
                           , EditWho
                           , CartonType
                           , UCCNo
                           , CartonGID
                           , CartonStatus
                           )
                     VALUES( @cPickSlipNo
                           , @nCartonNo
                           , 0
                           , 0
                           , @nQty
                           , GETDATE()
                           , @c_UserID
                           , GETDATE()
                           , @c_UserID
                           , ''
                           , IIF(@cScanType = 'ucc', @cInputValue1, '')
                           , ''
                           , 'INPROGRESS'
                           )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11155
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Insert into PackInfo.'
         GOTO EXIT_SP
      END
   END

   --Update UCC Status
   IF @cScanType = 'ucc'
   BEGIN
      UPDATE UCC WITH (ROWLOCK)
      SET  [Status] = '6'
         , EditWho = @c_UserID
         , EditDate = GETDATE()
         , TrafficCop = NULL
      WHERE Storerkey = @cStorerKey
      AND UCCNo = @cInputValue1

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 11156
         SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update into UCC.'
         GOTO EXIT_SP
      END
   END

   --Insert/Update SerialNo or AntiDiversion
   EXEC [API].[isp_TPACK_ExtPreUpd_Wrapper]
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
         , @cInputValue2      = @cInputValue2
         , @cInputValue3      = @cInputValue3
         , @cScanType         = @cScanType
         , @cSKU              = @cSKU
         , @nCartonNo         = @nCartonNo
         , @cLabelNo          = @cLabelNo
         , @cLabelLine        = @cLabelLine
         , @nQty              = @nQty
         , @c_UserID          = @c_UserID
         , @cLangCode         = @cLangCode
         , @b_Success         = @b_Success   OUTPUT
         , @n_ErrNo           = @n_ErrNo     OUTPUT
         , @c_ErrMsg          = @c_ErrMsg    OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue  = 3    
      GOTO EXIT_SP
   END

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
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



