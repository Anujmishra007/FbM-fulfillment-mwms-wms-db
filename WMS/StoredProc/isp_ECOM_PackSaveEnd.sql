/************************************************************************/    
/* Stored Proc: isp_ECOM_PackSaveEnd                                    */    
/* Creation Date: 11-JUN-2019                                           */    
/* Copyright: LF Logistics                                              */    
/* Written by: Wan                                                      */    
/*                                                                      */    
/* Purpose: Performance Tune                                            */    
/*        :                                                             */    
/* Called By: ECOM PackHeader - ue_saveend                              */    
/*          :                                                           */    
/* PVCS Version: 1.1                                                    */    
/*                                                                      */    
/* Version: 7.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date        Author   Ver   Purposes                                  */    
/* 2019-07-10  Wan01    1.1   Fixed. Order without Tracking#            */    
/************************************************************************/    
CREATE PROC isp_ECOM_PackSaveEnd    
           @c_PickSlipNo         NVARCHAR(10)    
         , @c_Orderkey           NVARCHAR(10)      
         , @n_SaveResult         INT            = '0'               
         , @c_SaveEndValidation  NCHAR(1)       = 'N'     
         , @b_Success            INT            OUTPUT    
         , @n_Err                INT            OUTPUT    
         , @c_ErrMsg             NVARCHAR(255)  OUTPUT    
AS    
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE      
           @n_StartTCnt       INT            = @@TRANCOUNT    
         , @n_Continue        INT            = 1    
    
         , @n_RowId           INT            = 1    
         , @n_CartonNo_PD     INT            = 0    
         , @n_CartonNo        INT            = 0    
         , @c_Storerkey       NVARCHAR(15)   = ''    
         , @c_RefNo           NVARCHAR(40)   = ''    
         , @c_TrackingNo      NVARCHAR(30)   = ''    
         , @c_WarningMsg      NVARCHAR(255)  = ''    
    
         , @c_ValidateTrackNo NVARCHAR(10)   = ''    
         , @CUR_PIF           CURSOR    
    
    
   SET @n_err      = 0    
   SET @c_errmsg   = ''    
    
   WHILE @@TRANCOUNT > 0     
   BEGIN    
      COMMIT TRAN    
   END    
    
   SELECT @c_TrackingNo = CASE WHEN ISNULL(RTRIM(OH.TrackingNo),'') <> ''     
                               THEN OH.TrackingNo     
                               ELSE ISNULL(RTRIM(OH.UserDefine04),'')     
                               END    
      ,   @c_Storerkey  = OH.Storerkey    
   FROM ORDERS OH WITH (NOLOCK)    
   WHERE OH.Orderkey = @c_Orderkey    
       
   SELECT @c_ValidateTrackNo = dbo.fnc_GetRight('', @c_Storerkey, '', 'ValidateTrackNo')    
    
   SET @CUR_PIF = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
   SELECT DISTINCT PD.CartonNo                  --(Wan01)    
         ,PIF.CartonNo    
         ,RefNo = ISNULL(PIF.RefNo,'')     
   FROM PACKDETAIL PD WITH (NOLOCK)    
   LEFT JOIN PACKINFO PIF WITH (NOLOCK) ON (PD.PickSlipNo = PIF.PickSlipNo)    
                                        AND(PD.CartonNo = PIF.CartonNo)    
   WHERE PD.PickSlipNo = @c_PickSlipNo    
   ORDER BY PD.CartonNo    
    
   OPEN @CUR_PIF    
   FETCH NEXT FROM @CUR_PIF INTO @n_CartonNo_PD    
                               , @n_CartonNo    
                               , @c_RefNo                                     
                                        
   WHILE @@FETCH_STATUS <> -1    
   BEGIN    
      -- Update Refno if ECOM Packing successfully Saved, 0:NOWORK, 1:SUCCESS, 2:No Save When Prompt To Save and ResetData    
      IF @n_SaveResult = 1 AND @c_ValidateTrackNo= '0' AND @n_CartonNo IS NOT NULL    
      BEGIN    
         IF @c_RefNo = '' AND @c_TrackingNo <> ''    
         BEGIN    
            UPDATE PACKINFO     
            SET RefNo = @c_TrackingNo    
            WHERE PickSlipNo = @c_PickSlipNo    
            AND CartonNo = @n_CartonNo    
            AND (RefNo = '' OR RefNo IS NULL)    
    
            IF @@ERROR <> 0    
            BEGIN    
               SET @n_Continue = 3    
               SET @n_Err    = 67890    
               SET @c_ErrMsg = ERROR_MESSAGE()    
               SET @c_ErrMsg = CONVERT(CHAR(5),@n_Err) + ': Error Update PACKINFO Table. (isp_ECOM_PackSaveEnd) '    
                             + '(' + @c_ErrMsg + ')'    
    
               GOTO QUIT_SP    
            END    
    
            SET @c_RefNo = @c_TrackingNo    
         END    
      END    
    
      IF @c_SaveEndValidation = 'Y' AND @n_Continue = 1    
      BEGIN    
         IF @n_CartonNo IS NULL    
         BEGIN    
            SET @n_Continue = 2    
            SET @c_WarningMsg = 'Missing Carton #: ' + CONVERT(NVARCHAR(10), @n_CartonNo_PD) + ' in PackInfo'    
         END    
    
         IF @n_Continue = 1 AND @n_RowId = 1 AND @c_RefNo <> @c_TrackingNo AND @c_TrackingNo <> ''   --(Wan01)    
         BEGIN    
            SET @n_Continue = 2    
            SET @c_WarningMsg = 'Tracking # not match on first CartonNo. Carton #: ' + CONVERT(NVARCHAR(10), @n_CartonNo)    
         END    
    
         IF @n_Continue = 1 AND @c_RefNo = ''    
         BEGIN    
            SET @n_Continue = 2    
            SET @c_WarningMsg = 'Tracking # is required. Carton #: ' + CONVERT(NVARCHAR(10), @n_CartonNo)    
         END    
    
         IF (@n_SaveResult IN (0,2) OR @c_ValidateTrackNo= '1') AND @n_Continue = 2    
         BEGIN    
            GOTO QUIT_SP     
         END    
      END    
    
      NEXT_REC:    
      SET @n_RowId = @n_RowId + 1    
      FETCH NEXT FROM @CUR_PIF INTO @n_CartonNo_PD    
                                 ,  @n_CartonNo    
                                 ,  @c_RefNo      
   END    
   CLOSE @CUR_PIF    
   DEALLOCATE @CUR_PIF     
    
QUIT_SP:    
   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SET @b_Success = 0    
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
      ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_StartTCnt    
         BEGIN    
            COMMIT TRAN    
         END    
      END    
    
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_ECOM_PackSaveEnd'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
   END    
   ELSE    
   BEGIN    
      SET @b_Success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
    
      IF @c_WarningMsg <> ''    
      BEGIN    
         SET @b_Success = 2    
         SET @c_ErrMsg = @c_WarningMsg    
      END    
   END    
    
   WHILE @@TRANCOUNT < @n_StartTCnt    
   BEGIN    
      BEGIN TRAN    
   END    
END -- procedure 