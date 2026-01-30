SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtResetCtn03                                      */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Custom Reset Carton Function                                 */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-10-29   1.0  GCH225     Cloned from isp_TPS_ResetCtnP03 (TPS-805)        */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtResetCtn03] (
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
   
   DECLARE @cPackSerialNoKey     NVARCHAR(10)
         , @cSNSerialNoKey       NVARCHAR(10)
         , @cSerialNo            NVARCHAR(50)
         , @cSerialNoCapture     NVARCHAR(1)
         , @cSKU                 NVARCHAR(20)
         , @cUCCNo               NVARCHAR(20)

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 

   BEGIN TRAN

   IF @bResetAll = 1
   BEGIN
      DELETE CT
      FROM CARTONTRACK CT
      WHERE EXISTS ( SELECT 1 
                     FROM PACKDETAIL P (NOLOCK)
                     WHERE P.PickSlipNo = @cPickSlipNo
                     AND P.LabelNo = CT.LabelNo
                   )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 13701    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete from CartonTrack Table.'  
         GOTO EXIT_SP  
      END

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
            SET @n_ErrNo = 13702    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND (@cDropID = '' OR DropID = @cDropID)

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 13703    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKDETAIL Table.'  
         GOTO EXIT_SP  
      END
   END
   ELSE
   BEGIN
      DELETE CT
      FROM CARTONTRACK CT
      WHERE EXISTS ( SELECT 1 
                     FROM PACKDETAIL P (NOLOCK)
                     WHERE P.PickSlipNo = @cPickSlipNo
                     AND P.CartonNo = @nCartonNo
                     AND P.LabelNo = CT.LabelNo
                   )

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 13704    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete from CartonTrack Table.'  
         GOTO EXIT_SP  
      END

      SELECT @cUCCNo = UCCNo
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND UCCNo <> ''

      IF @@ROWCOUNT > 0
      BEGIN
         UPDATE UCC WITH (ROWLOCK)
         SET [Status] = '3'
           , EditDate = GETDATE()
           , EditWho = @c_UserID
         WHERE UCCNo = @cUCCNo

         IF @@ERROR <> 0
         BEGIN
            SET @n_Continue = 3  
            SET @n_ErrNo = 13705    
            SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Update the UCC Table.'  
            GOTO EXIT_SP  
         END
      END
      
      DELETE FROM PACKDETAIL
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      
      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3  
         SET @n_ErrNo = 13706    
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Failed to Delete the PACKDETAIL Table.'  
         GOTO EXIT_SP  
      END
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



