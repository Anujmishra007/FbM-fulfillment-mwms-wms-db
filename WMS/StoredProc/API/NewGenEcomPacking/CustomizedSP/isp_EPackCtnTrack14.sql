SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
/************************************************************************/    
/* Trigger: isp_EPackCtnTrack14                                         */    
/* Creation Date: 2025-10-14                                            */    
/* Copyright: Maersk                                                    */    
/* Written by:                                                          */    
/*                                                                      */    
/* Purpose: WMS-24509 - CN Dyson SCE_New_EcomPacking_TPPrint            */    
/*        : FCR-8269 based on isp_EPackCtnTrack11                       */    
/* Called By: n_cst_packcarton_ecom                                     */    
/*          : ue_getcartontrackno                                       */    
/*        :                                                             */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 7.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date        Author   Ver   Purposes                                  */    
/* 2025-10-14  Sean01   1.0   FCR-8269 - Set CartonTrack.CarrierRef1 =  */
/*                                        orderKey + current cartonNo   */    
/************************************************************************/  
CREATE OR ALTER  PROC [dbo].[isp_EPackCtnTrack14]  
         @c_PickSlipNo  NVARCHAR(10)  
      ,  @n_CartonNo    INT  
      ,  @b_CCTVREFRESHTRACKNO  INT  = 0       -- Sean
      ,  @b_CloseCarton   INT  = 0            -- Sean
      ,  @b_FetchNextCarton  INT  = 0                 -- Sean
      ,  @c_CTNTrackNo  NVARCHAR(40)         OUTPUT  
      ,  @b_Success     INT = 0              OUTPUT   -- 0:Fail, 1:Success 2:Success with Track # is lock  
      ,  @n_err         INT = 0              OUTPUT  
      ,  @c_errmsg      NVARCHAR(255) = ''   OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @n_StartTCnt    INT  
         , @n_Continue     INT  
  
         , @n_Cnt          INT  
         , @n_RowRef       BIGINT  
         , @c_Orderkey     NVARCHAR(10)  
         , @c_Storerkey    NVARCHAR(15)  
  
         , @c_Shipperkey   NVARCHAR(10)  
         , @c_ShipperName  NVARCHAR(250)  
  
         , @c_TrackingNo   NVARCHAR(40) = ''  
  
         , @c_SKIPTRKNO       NVARCHAR(1)  = 'N'    
         , @c_ECOMPlatform    NVARCHAR(20) = ''   
     
   DECLARE @c_TableName       NVARCHAR(15)= ''  
         , @c_CartonNo        NVARCHAR(10)= ''  
       --  , @c_Orderkey        NVARCHAR(10)= ''        
      --   , @c_Storerkey       NVARCHAR(15)= ''   
         , @c_TaskBatchNo     NVARCHAR(10)= ''   
           
         , @c_Command         NVARCHAR(1000)=''  
         , @c_TransmitlogKey  NVARCHAR(10)  =''  
         , @c_IP              VARCHAR(20)   =''  
         , @c_Port            VARCHAR(10)   =''  
         , @n_ThreadPerAcct   INT           =0  
         , @n_MilisecondDelay INT           =0  
         , @c_APP_DB_Name     VARCHAR(30)   =''      
         , @n_ThreadPerStream INT           =0  
         , @c_IniFilePath     NVARCHAR(200) =''  
         , @c_DataStream      VARCHAR(10)   ='6157'  
         , @b_SuccessOld      INT     
         , @c_UpdateCT        NVARCHAR(1) = 'N'    
        -- , @n_RowRef          BIGINT     
         , @c_Facility        NVARCHAR(5)       
         , @c_SValue          NVARCHAR(50)     
         , @c_Option1         NVARCHAR(50) = ''     
         , @c_Option2         NVARCHAR(50) = ''     
         , @c_Option3         NVARCHAR(50) = ''     
         , @c_Option4         NVARCHAR(50) = ''    
         , @c_Option5         NVARCHAR(4000) = ''   
        -- , @c_ECOMPlatform    NVARCHAR(20) = ''     
         , @c_ECPlatform_JSON NVARCHAR(MAX) = ''     
         , @c_TL2KeyPrefix    NVARCHAR(MAX) = ''     
         , @c_Key1Prefix      NVARCHAR(20) = ''     
         , @c_Key2Prefix      NVARCHAR(20) = ''     
         , @c_Key3Prefix      NVARCHAR(20) = ''   

   SET @n_StartTCnt = @@TRANCOUNT  
   SET @n_Continue = 1  
   SET @b_Success  = 1  
   SET @n_err      = 0  
   SET @c_errmsg   = ''  
  
   WHILE @@TRANCOUNT > 0  
   BEGIN  
      COMMIT TRAN  
   END  
  
   SET @c_Orderkey = ''  
   SELECT @c_Orderkey = PACKHEADER.Orderkey  
         ,@c_Storerkey= ORDERS.Storerkey  
   ,@c_ECOMPlatform  = ORDERS.ECOM_Platform    
   FROM PACKHEADER WITH (NOLOCK)  
   JOIN ORDERS WITH (NOLOCK) ON ORDERS.OrderKey = PACKHEADER.OrderKey  
   WHERE PickSlipNo = @c_PickSlipNo  
  
   --IF @c_Orderkey = ''  
   --BEGIN  
   --   GOTO QUIT_SP  
   --END  
   IF @c_Orderkey = ''          
   BEGIN   
      SET @n_continue = 3          
      SET @n_err = 60010            
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Orderkey is required to get Tracking #. (isp_EPackCtnTrack14)'           
      GOTO QUIT_SP                        
   END    
  
   SET @n_Cnt = 0  
  
       
   IF EXISTS (SELECT 1 FROM dbo.CODELKUP (NOLOCK) WHERE LISTNAME='SKIPTRKNO' AND Storerkey = @c_Storerkey AND long = @c_ECOMPlatform)    
   BEGIN    
      SET @c_SKIPTRKNO = 'Y'    
      EXEC isp_EPackCtnTrack15
            @c_PickSlipNo    = @c_PickSlipNo  
          , @n_CartonNo      = @n_CartonNo  
          , @b_CCTVREFRESHTRACKNO = @b_CCTVREFRESHTRACKNO
          , @b_CloseCarton  = @b_CloseCarton
          , @c_CTNTrackNo    = @c_CTNTrackNo OUTPUT   
          , @b_Success       = @b_Success    OUTPUT  
          , @n_Err           = @n_Err        OUTPUT  
          , @c_ErrMsg        = @c_ErrMsg     OUTPUT  
  
  
      IF @n_err > 0  
      BEGIN  
         SET @n_continue = 3  
         SET @n_err = @n_Err  
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+ @c_ErrMsg  
         GOTO QUIT_SP  
      END  
  
      GOTO QUIT_SP  
  
   END   
   ELSE  
   BEGIN  
      SET @c_SKIPTRKNO = 'N'    
      GOTO EPackCtnTrack01  
   END  
  
   EPackCtnTrack01:   
  
   IF @n_CartonNo = 1  
   BEGIN  
      GOTO UPDATE_PACKINFO  
   END  
  
   SELECT @c_TrackingNo = CASE WHEN ISNULL(PI.TrackingNo,'') <> '' THEN RTRIM(PI.TrackingNo) ELSE ISNULL(RTRIM(PI.RefNo),'') END  
   FROM dbo.PackInfo AS PI WITH (NOLOCK)  
   WHERE PI.PickSlipNo = @c_PickSlipNo  
   AND  CartonNo = @n_CartonNo  
  
   IF @c_CTNTrackNo = @c_TrackingNo      
   BEGIN  
      GOTO QUIT_SP  
   END  
  
   BEGIN TRAN  
   SET @c_CTNTrackNo = ''  
   EXEC ispAsgnTNo2  
     @c_OrderKey    = @c_OrderKey  
   , @c_LoadKey     = ''  
   , @b_Success     = @b_Success    OUTPUT  
   , @n_Err         = @n_Err        OUTPUT  
   , @c_ErrMsg      = @c_ErrMsg     OUTPUT  
   , @b_ChildFlag   = 1  
   , @c_TrackingNo  = @c_CTNTrackNo OUTPUT  
  
   IF ISNULL(RTRIM(@c_CTNTrackNo),'') = ''  
   BEGIN  
      SET @n_continue = 3  
      SET @n_err = 60010  
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Get Empty Tracking #. (isp_EPackCtnTrack14)'  
      GOTO QUIT_SP  
   END

   --(Sean01) - START
   IF @n_CartonNo > 1
   BEGIN   
      UPDATE CartonTrack  WITH (ROWLOCK)
      SET CarrierRef1 = @c_OrderKey + CAST(@n_CartonNo AS NVARCHAR)
      WHERE TrackingNo = @c_CTNTrackNo;
      
      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 60040
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Insert PACKINFO Table. (isp_EPackCtnTrack14)'
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '
         GOTO QUIT_SP
      END
   END
   --(Sean01) - END  
  
   UPDATE_PACKINFO:  
   IF EXISTS ( SELECT 1  
               FROM PACKINFO WITH (NOLOCK)  
               WHERE PickSlipNo = @c_PickSlipNo  
               AND CartonNo = @n_CartonNo  
              )  
   BEGIN  
      IF @n_CartonNo = 1  
      BEGIN  
         SET @b_Success = 1  
         GOTO QUIT_SP  
      END  
  
      UPDATE PACKINFO WITH (ROWLOCK)  
      SET TrackingNo = @c_CTNTrackNo       
         ,TrafficCop = NULL  
         ,EditWho = SUSER_SNAME()  
         ,EditDate= GETDATE()  
      WHERE PickSlipNo = @c_PickSlipNo  
      AND CartonNo = @n_CartonNo  
  
      SET @n_err = @@ERROR  
      IF @n_err <> 0  
      BEGIN  
         SET @n_continue = 3  
         SET @n_err = 60020  
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Update PACKINFO Table. (isp_EPackCtnTrack14)'  
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '  
         GOTO QUIT_SP  
      END  
   END  
   ELSE  
   BEGIN  
      INSERT INTO PACKINFO  
            (  PickSlipNo  
            ,  CartonNo  
            --,  RefNo                        
            ,  Weight  
            ,  Cube  
            ,  Height  
            ,  Length  
            ,  Width  
            ,  TrackingNo                      
            )  
      VALUES(  @c_PickSlipNo  
            ,  @n_CartonNo               
            ,  0.00  
            ,  0.00  
            ,  0.00  
            ,  0.00  
            ,  0.00  
            ,  @c_CTNTrackNo               
            )  
      SET @n_err = @@ERROR  
      IF @n_err <> 0  
      BEGIN  
         SET @n_continue = 3  
         SET @n_err = 60030  
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Insert PACKINFO Table. (isp_EPackCtnTrack14)'  
                        + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '  
         GOTO QUIT_SP  
      END  
   END  
  
   SET @b_Success = 2  
  
   WHILE @@TRANCOUNT > 0  
   BEGIN  
      COMMIT TRAN  
   END  
  
   GOTO QUIT_SP  
  
   QUIT_SP:  
   IF @n_Continue=3  -- Error Occured - Process And Return  
   BEGIN  
      SET @b_Success = 0  
  
      ROLLBACK TRAN  
  
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'isp_EPackCtnTrack14'  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
   END  
  
   WHILE @@TRANCOUNT < @n_StartTCnt  
   BEGIN  
      BEGIN TRAN  
   END  
END -- procedure  
GO
GRANT EXECUTE ON  [dbo].[isp_EPackCtnTrack14] TO [NSQL]
GO
