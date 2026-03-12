SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtResetCtn01                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Custom Reset Carton Function                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-12-10   1.0  Sean       Cloned from isp_TPS_ResetCtnP01                  */
/* 2025-12-23   1.1  Sean       Remove the UCCToUPC/UCCToDropID                  */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtResetCtn01] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @bResetAll            BIT               = 0
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
   
   DECLARE @cUCCNo               NVARCHAR(20)

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   BEGIN TRAN

   -- Reset All Cartons
   IF @bResetAll = 1
   BEGIN
      -- Update SerialNo status
      UPDATE SN WITH (ROWLOCK)
      SET SN.[Status] = '1'
        , SN.OrderKey = ''
        , SN.OrderLineNumber = ''
        , SN.LabelLine = ''
        , SN.CartonNo = ''
        , SN.PickSlipNo = ''
        , SN.EditDate = GETDATE()
        , SN.EditWho = @c_UserID
      FROM SerialNo SN
      WHERE SN.PickSlipNo = @cPickSlipNo
      AND SN.StorerKey = @cStorerKey
      AND SN.[Status] < '6'

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 14604    
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Failed to Update SerialNo Table.'  
         GOTO EXIT_SP  
      END

      -- Update SerialNo for order-level records (if OrderKey exists but no PickSlipNo)
      IF ISNULL(@cOrderKey, '') = ''
      BEGIN
         SELECT @cOrderKey = OrderKey
         FROM PickHeader (NOLOCK)
         WHERE PickHeaderKey = @cPickSlipNo
      END

      IF ISNULL(@cOrderKey, '') <> ''
      BEGIN
         UPDATE SN WITH (ROWLOCK)
         SET SN.[Status] = '1'
           , SN.OrderKey = ''
           , SN.OrderLineNumber = ''
           , SN.LabelLine = ''
           , SN.CartonNo = ''
           , SN.PickSlipNo = ''
           , SN.EditDate = GETDATE()
           , SN.EditWho = @c_UserID
         FROM SerialNo SN
         WHERE SN.OrderKey = @cOrderKey
         AND SN.StorerKey = @cStorerKey
         AND SN.[Status] IN ('1', '6')
         AND ISNULL(SN.OrderKey, '') <> ''

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 14605    
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Failed to Update SerialNo Table (Order Level).'  
            GOTO EXIT_SP  
         END
      END

      -- Reset UCC Status
      IF EXISTS ( SELECT 1 
                  FROM PACKINFO P(NOLOCK)
                  WHERE P.PickSlipNo = @cPickSlipNo
                  AND P.UCCNo <> ''
                  AND EXISTS (SELECT 1 
                              FROM PACKDETAIL PD(NOLOCK)
                              WHERE PD.PickSlipNo = P.PickSlipNo
                              AND (@cDropID = '' OR PD.DropID = @cDropID)
                             )
      )
      BEGIN
         UPDATE U WITH (ROWLOCK)
         SET U.[Status] = '3'
           , U.EditDate = GETDATE()
           , U.EditWho = @c_UserID
         FROM UCC U
         WHERE EXISTS ( SELECT 1 
                        FROM PACKINFO P(NOLOCK)
                        WHERE P.PickSlipNo = @cPickSlipNo
                        AND P.UCCNo = U.UCCNo
                        AND EXISTS (SELECT 1 
                                    FROM PACKDETAIL PD(NOLOCK)
                                    WHERE PD.PickSlipNo = P.PickSlipNo
                                    AND (@cDropID = '' OR PD.DropID = @cDropID)
                                   )
                      )

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 14603 
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END

      -- Delete PackDetail
      DELETE FROM PackDetail
      WHERE PickSlipNo = @cPickSlipNo
      AND (@cDropID = '' OR DropID = @cDropID)

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 14601    
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete PackDetail Table.'  
         GOTO EXIT_SP  
      END
   END
   -- Reset Single Carton
   ELSE
   BEGIN
      -- Update SerialNo status for specific carton
      UPDATE SN WITH (ROWLOCK)
      SET SN.[Status] = '1'
        , SN.OrderKey = ''
        , SN.OrderLineNumber = ''
        , SN.LabelLine = ''
        , SN.CartonNo = ''
        , SN.PickSlipNo = ''
        , SN.EditDate = GETDATE()
        , SN.EditWho = @c_UserID
      FROM SerialNo SN
      WHERE SN.PickSlipNo = @cPickSlipNo
      AND SN.CartonNo = @nCartonNo
      AND SN.StorerKey = @cStorerKey
      AND SN.[Status] < '6'

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 14606    
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Failed to Update SerialNo Table.'  
         GOTO EXIT_SP  
      END

      -- Check if carton doesn't have SerialNo records in PickSlip, try order level
      IF @@ROWCOUNT = 0
      BEGIN
         IF ISNULL(@cOrderKey, '') = ''
         BEGIN
            SELECT @cOrderKey = OrderKey
            FROM PickHeader (NOLOCK)
            WHERE PickHeaderKey = @cPickSlipNo
         END

         IF ISNULL(@cOrderKey, '') <> ''
         BEGIN
            UPDATE SN WITH (ROWLOCK)
            SET SN.[Status] = '1'
              , SN.OrderKey = ''
              , SN.OrderLineNumber = ''
              , SN.LabelLine = ''
              , SN.CartonNo = ''
              , SN.PickSlipNo = ''
              , SN.EditDate = GETDATE()
              , SN.EditWho = @c_UserID
            FROM SerialNo SN
            WHERE SN.OrderKey = @cOrderKey
            AND SN.StorerKey = @cStorerKey
            AND SN.[Status] IN ('1', '6')

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3  
               SET @n_ErrNo = 14607    
               SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Failed to Update SerialNo Table (Order Level).'  
               GOTO EXIT_SP  
            END
         END
      END

       -- Get UCC number directly from PackInfo
      SELECT @cUCCNo = UCCNo
      FROM PackInfo (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND UCCNo <> ''
      AND UCCNo IS NOT NULL

      -- Update UCC status if exists
      IF @@ROWCOUNT > 0 AND ISNULL(@cUCCNo, '') <> ''
      BEGIN
         UPDATE UCC WITH (ROWLOCK)
         SET [Status] = '3'
           , EditDate = GETDATE()
           , EditWho = @c_UserID
         WHERE UCCNo = @cUCCNo
         AND [Status] IN ('1','2','3','4','6')

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 14609    
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Failed to Update UCC Table.'  
            GOTO EXIT_SP  
         END
      END

      -- Delete PackDetail for the carton
      DELETE FROM PackDetail
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 14608    
         SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete PackDetail Table.'  
         GOTO EXIT_SP  
      END
   END

EXIT_SP:
   IF @n_Continue = 3  -- Error Occurred - Process And Return      
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