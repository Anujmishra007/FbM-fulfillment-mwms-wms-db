if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_GLBL24]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [dbo].[isp_GLBL24]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store Procedure: isp_GLBL24                                          */
/* Creation Date: 18-AUG-2020                                           */
/* Copyright: LFL                                                       */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-14755 - [TW] LOR Exceed Retrieve Carton ID_CR           */ 
/*                                                                      */
/* Input Parameters:  @c_PickSlipNo-Pickslipno, @n_CartonNo - CartonNo  */
/*                    storerconfig: GenLabelNo_SP                       */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage: Call from isp_GenLabelNo_Wrapper                              */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver.  Purposes                                  */
/* 2021-04-21   WLChooi 1.1   WMS-16869 Fix Generate Wrong LabelNo when */
/*                            RealTimePacking is turned on (WL01)       */
/************************************************************************/

CREATE PROC isp_GLBL24 ( 
         @c_PickSlipNo   NVARCHAR(10) 
      ,  @n_CartonNo     INT
      ,  @c_LabelNo      NVARCHAR(20)   OUTPUT )
AS
BEGIN
   SET NOCOUNT ON   
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
      
   DECLARE @n_StartTCnt          INT
         , @n_Continue           INT
         , @b_Success            INT 
         , @n_Err                INT  
         , @c_ErrMsg             NVARCHAR(255)
         
   DECLARE @c_Label_SeqNo        NVARCHAR(10)
          ,@c_Consigneekey       NVARCHAR(15)
          ,@c_Storerkey          NVARCHAR(15)
          ,@c_Keyname            NVARCHAR(18)
          ,@n_Cntno              INT
          ,@n_GetCntNo           INT
          ,@c_ContainerType      NVARCHAR(20)
          ,@n_MaxCartonNo        INT

   SET @n_StartTCnt        = @@TRANCOUNT
   SET @n_Continue         = 1
   SET @b_Success          = 0
   SET @n_Err              = 0
   SET @c_ErrMsg           = ''
   
   --SET @c_LabelNo = ''   --WL01
   SET @n_Cntno = 0
   SET @n_GetCntNo = 1

   SELECT @c_ContainerType = ISNULL(O.ContainerType,'')
   FROM PACKHEADER PH (NOLOCK) 
   JOIN ORDERS O (NOLOCK) ON PH.OrderKey = O.OrderKey 
   WHERE PH.PickSlipNo = @c_PickSlipNo

   --WL01 - S
   --SELECT @n_MaxCartonNo = MAX(Cartonno)
   --FROM PackDetail (NOLOCK)
   --WHERE PickSlipNo = @c_Pickslipno
   
   --SET @n_CartonNo = ISNULL(@n_MaxCartonNo,0) + 1    

   --IF ISNULL(@n_CartonNo, 0) = 0
   --   SET @n_CartonNo = 1 
   
   IF @c_LabelNo <> 'REGEN'
   BEGIN
      EXECUTE nspg_GetKey    
            'PACKNO_LOR',     
            20 ,    
            @c_LabelNo  OUTPUT,    
            @b_success  OUTPUT,    
            @n_err      OUTPUT,    
            @c_errmsg   OUTPUT  

      GOTO QUIT_SP
   END
   --WL01 - E

   IF @c_ContainerType = 'C'
   BEGIN 
      SELECT @c_LabelNo = LTRIM(RTRIM(O.UserDefine03)) + SUBSTRING(PH.Pickslipno, 4, 7) 
                        + RIGHT('00'+ CONVERT(NVARCHAR(5), @n_CartonNo),3)  
      FROM PACKHEADER PH (NOLOCK) 
      JOIN ORDERS O (NOLOCK) ON PH.OrderKey = O.OrderKey 
      WHERE PH.PickSlipNo = @c_Pickslipno
   END
   ELSE
   BEGIN
      SELECT @c_LabelNo = SUBSTRING(PH.Pickslipno, 4, 7) + RIGHT('00'+ CONVERT(NVARCHAR(5), @n_CartonNo),3)  
      FROM PACKHEADER PH (NOLOCK) 
      JOIN ORDERS O (NOLOCK) ON PH.OrderKey = O.OrderKey 
      WHERE PH.PickSlipNo = @c_Pickslipno
   END

   --SELECT @c_LabelNo

QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_Success = 0     
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt 
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "isp_GLBL24"
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE 
   BEGIN
      SELECT @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt 
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END

END
GO
GRANT EXECUTE ON isp_GLBL24 TO NSQL
GO
