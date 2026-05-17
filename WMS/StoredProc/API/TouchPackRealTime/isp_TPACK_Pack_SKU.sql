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
/* 2026-02-11   2.0  GCH225     UWP:45984: Fix for PreCartonize issue            */
/* 2026-04-01   3.0  GCH225     UWP-52975: Fine tune performance                 */
/* 2026-05-14   3.1  GCH225     FCR-13198: Fix Update Multi Line PackDetail      */
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
         , @nExpQty              INT
         , @nSUMQty              INT
         , @nTMPQty              INT
         , @nRemainingQty        INT
         , @nCountTLN            INT
   
   DECLARE @tLineNo TABLE (
        RowID     INT IDENTITY(1,1) PRIMARY KEY 
      , LabelLine NVARCHAR(20) NOT NULL
      , Qty       INT DEFAULT(0)
      , ExpQty    INT DEFAULT(0)
   )

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
   SET @nExpQty            = 0
   SET @nSUMQty            = 0
   SET @nTMPQty            = 0
   SET @nRemainingQty      = 0
   SET @nCountTLN          = 0

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
      IF @cOrderKey <> ''
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
                             , @cOrderKey
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

   -- Skip double-check to improve performance.
   -- -- Perform Check the Qty
   -- EXEC [API].[isp_TPACK_ValidateQtyPack]
   --      @cType             = @cType            
   --    , @bIsDiscrete       = @bIsDiscrete      
   --    , @bIsCustom         = @bIsCustom        
   --    , @cPickSlipNo       = @cPickSlipNo       
   --    , @cOrderKey         = @cOrderKey         
   --    , @cLoadKey          = @cLoadKey          
   --    , @cDropID           = @cDropID  
   --    , @cStorerKey        = @cStorerKey        
   --    , @cFacility         = @cFacility  
   --    , @cInputValue1      = @cInputValue1
   --    , @cScanType         = @cScanType
   --    , @cSKU              = @cSKU
   --    , @c_UserID          = @c_UserID
   --    , @cLangCode         = @cLangCode
   --    , @nQty              = @nQty
   --    , @b_Success         = @b_Success   OUTPUT
   --    , @n_ErrNo           = @n_ErrNo     OUTPUT
   --    , @c_ErrMsg          = @c_ErrMsg    OUTPUT

   -- IF @b_Success = 0
   -- BEGIN
   --    SET @n_Continue  = 3    
   --    GOTO EXIT_SP
   -- END

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
         INSERT INTO @tLineNo (LabelLine, Qty, ExpQty)
         SELECT LabelLine, Qty, ExpQty
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND UPC = @cInputValue1
         AND (@cInputValue3 = '' OR LOTTABLEVALUE = @cInputValue3)
         ORDER BY LabelLine ASC
      END
      ELSE IF @cInputValue3 <> ''
      BEGIN
         INSERT INTO @tLineNo (LabelLine, Qty, ExpQty)
         SELECT LabelLine, Qty, ExpQty
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND UPC = ''
         AND LOTTABLEVALUE = @cInputValue3
         ORDER BY LabelLine ASC
      END
      ELSE -- all other scan type
      BEGIN
         INSERT INTO @tLineNo (LabelLine, Qty, ExpQty)
         SELECT LabelLine, Qty, ExpQty 
         FROM PACKDETAIL (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND LabelNo = @cLabelNo
         AND SKU = @cSKU
         AND (UPC = '' OR UPC IS NULL)
         AND (LOTTABLEVALUE = '' OR LOTTABLEVALUE IS NULL)
         ORDER BY LabelLine ASC
      END

      SELECT @nCountTLN = COUNT(1) 
      FROM @tLineNo

      IF @nCountTLN >= 1
      BEGIN
         IF @nCountTLN > 1
         BEGIN
            SELECT  @nExpQty = ISNULL(SUM(ExpQty), 0)
                  , @nSUMQty = ISNULL(SUM(Qty), 0)
            FROM @tLineNo

            IF @nExpQty > 0
            BEGIN
               IF @nExpQty = (@nSUMQty + @nQty)
               BEGIN
                  UPDATE @tLineNo
                  SET Qty = ExpQty
               END 
               ELSE IF @nExpQty > (@nSUMQty + @nQty)
               BEGIN
                  SET @nTMPQty = @nQty
                  WHILE @nTMPQty > 0
                  BEGIN               
                     SET @cLabelLine = NULL;
                     SET @nRemainingQty = 0;

                     SELECT TOP 1 @cLabelLine = LabelLine
                                , @nRemainingQty = ExpQty - Qty
                     FROM @tLineNo
                     WHERE Qty < ExpQty
                     ORDER BY LabelLine ASC

                     IF @cLabelLine IS NULL OR @nRemainingQty <= 0
                        BREAK;

                     IF @nRemainingQty >= @nTMPQty
                     BEGIN
                        UPDATE @tLineNo
                        SET Qty = Qty + @nTMPQty
                        WHERE LabelLine = @cLabelLine

                        SET @nTMPQty = 0
                     END
                     ELSE
                     BEGIN
                        UPDATE @tLineNo
                        SET Qty = ExpQty
                        WHERE LabelLine = @cLabelLine

                        SET @nTMPQty = @nTMPQty - @nRemainingQty
                     END
                  END
               END
               ELSE
               BEGIN
                  SET @n_Continue = 3
                  SET @n_ErrNo    = 11157
                  SET @c_ErrMsg   =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--Abnormal: Total packed quantity exceeds expected quantity. Please check with supervisor.'
                  GOTO EXIT_SP
               END
            END
            ELSE
            BEGIN
               UPDATE @tLineNo
               SET Qty = Qty + @nQty
               WHERE RowID = 1
            END

            SET @cLabelLine = ''
         END
         ELSE IF @nCountTLN = 1
         BEGIN
            SELECT @cLabelLine = LabelLine
            FROM @tLineNo

            UPDATE @tLineNo
            SET Qty = Qty + @nQty
            WHERE RowID = 1
         END

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
      UPDATE PD
      SET PD.Qty = TLN.Qty
         , PD.EditWho = @c_UserID
         , PD.EditDate = GETDATE()
      FROM PACKDETAIL PD WITH (ROWLOCK)
      INNER JOIN @tLineNo TLN
      ON PD.LabelLine = TLN.LabelLine
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND LabelNo = @cLabelNo

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