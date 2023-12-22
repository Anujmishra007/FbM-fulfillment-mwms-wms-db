SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_packing_list_144_rdt                                */
/* Creation Date: =11-OCT-2023                                          */
/* Copyright: Maersk                                                    */
/* Written by: CHONGCS                                                  */
/*                                                                      */
/* Purpose: WMS-23695 - [CN] Sephora B2C Packing List new format NEW    */
/*        :                                                             */
/* Called By: r_dw_packing_list_144_rdt                                 */
/*          :                                                           */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE OR ALTER PROC isp_packing_list_144_rdt
            @c_Pickslipno NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT 
         , @c_Loadkey         NVARCHAR(10) = ''
         , @c_Orderkey        NVARCHAR(10) = ''
         , @n_Err             INT = 0
         , @c_ErrMsg          NVARCHAR(255) = ''
         , @b_success         INT = 1
         , @c_OHUDF03         NVARCHAR(30)
         , @c_GetStorerkey    NVARCHAR(20)
         , @c_RTNNO1          NVARCHAR(10)=''
         , @c_RTNNO2          NVARCHAR(10)=''
         , @c_RTNNO3          NVARCHAR(10)=''
         , @c_RTNNotes1       NVARCHAR(4000)=''
         , @c_RTNNotes2       NVARCHAR(4000)=''
         , @c_RTNNotes3       NVARCHAR(4000)=''
         , @c_field12         NVARCHAR(4000)=''
         , @c_field13         NVARCHAR(4000)=''


   SELECT @c_GetStorerkey = OH.storerkey,
          @c_OHUDF03 = OH.UserDefine03
   FROM PACKHEADER PH WITH (NOLOCK)
   JOIN ORDERS     OH WITH (NOLOCK) ON (PH.Orderkey = OH.Orderkey)
   WHERE PH.Pickslipno = @c_Pickslipno

   SELECT    @c_RTNNO1 = ISNULL(MAX(CASE WHEN CL.Code2 = '1'  THEN ISNULL(RTRIM(CL.Short),'') ELSE '' END),'')
            ,@c_RTNNO2 = ISNULL(MAX(CASE WHEN CL.Code2 = '2'  THEN ISNULL(RTRIM(CL.Short),'') ELSE '' END),'')
            ,@c_RTNNO3 = ISNULL(MAX(CASE WHEN CL.Code2 = '3'  THEN ISNULL(RTRIM(CL.Short),'') ELSE '' END),'')
            ,@c_RTNNotes1 = ISNULL(MAX(CASE WHEN CL.Code2 = '1'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')
            ,@c_RTNNotes2 = ISNULL(MAX(CASE WHEN CL.Code2 = '2'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')
            ,@c_RTNNotes3 = ISNULL(MAX(CASE WHEN CL.Code2 = '3'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')
            ,@c_field12 = ISNULL(MAX(CASE WHEN CL.Code2 = '1'  THEN ISNULL(RTRIM(CL.long),'') ELSE '' END),'')
            ,@c_field13 = ISNULL(MAX(CASE WHEN CL.Code2 = '1'  THEN ISNULL(RTRIM(CL.udf01),'') ELSE '' END),'')
   FROM CODELKUP CL WITH (NOLOCK)
   WHERE  CL.LISTNAME='Sephora2C5' AND CL.code=@c_OHUDF03 AND CL.Storerkey = @c_getstorerkey


   SELECT  N'总件数:' as A1

         , ISNULL(OH.Notes,'') AS OHNotes
         , @c_RTNNO1 AS RTNNO
         , @c_RTNNotes1 AS RTNNotes
         , CONVERT(NVARCHAR(10),GETDATE(),101) AS PrnDate
         , N'打印日期:' AS A2
         , N'产品货号' AS A3
        , OH.Externorderkey as ExternOrderkey
         , N'产品名称' AS A4
         , N'数量'  AS A5
         , N'收件人备注需求'     AS A6
         , N'订单号:'     AS B1
         , N'波次号:' AS B2
         , SKU.SKU AS SKU
         , CASE WHEN LEN(SKU.DESCR)>30 THEN SUBSTRING(SKU.DESCR,1,30) + '...' ELSE RTRIM(SKU.DESCR) END  AS DESCR
         , OH.Orderkey as Orderkey
         , SUM(PDET.Qty) as Qty
         , @c_field12  AS A7
         , PH.PickSlipNo
         , @c_RTNNO2 AS RTNNO2
         , @c_RTNNO3 AS RTNNO3
         , @c_RTNNotes2 AS RTNNotes2
         , @c_RTNNotes3 AS RTNNotes3
         , @c_field13 AS Field13
   FROM PACKHEADER PH WITH (NOLOCK)
   JOIN PACKDETAIL PDET WITH (NOLOCK) ON (PDET.Pickslipno = PH.Pickslipno)
   JOIN ORDERS     OH WITH (NOLOCK) ON (PH.Orderkey = OH.Orderkey)
   JOIN SKU       SKU WITH (NOLOCK) ON (PDET.Storerkey = SKU.Storerkey)
                                   AND (PDET.Sku = SKU.Sku)
  -- LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.LISTNAME ='Sephora2C5' AND C.Code =OH.UserDefine03 AND c.Storerkey = OH.StorerKey
   WHERE PH.Pickslipno = @c_Pickslipno
   GROUP BY OH.Orderkey
         , ISNULL(OH.Notes,'')
       --  , ISNULL(c.Short,'') 
       --  , ISNULL(C.notes,'')
         , SKU.SKU
         , SKU.DESCR
         , OH.Externorderkey
         , PH.PickSlipNo--,ISNULL(C.Long,'') 
   ORDER BY PH.PickSlipNo,SKU.SKU
QUIT_SP:
  
   IF @n_continue=3  -- Error Occured - Process And Return  
    BEGIN  
       SELECT @b_success = 0  
       IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt  
       BEGIN  
          ROLLBACK TRAN  
       END  
       ELSE  
       BEGIN  
          WHILE @@TRANCOUNT > @n_starttcnt  
          BEGIN  
             COMMIT TRAN  
          END  
       END  
       execute nsp_logerror @n_err, @c_errmsg, "isp_packing_list_144_rdt"  
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
       RETURN  
    END  
    ELSE  
    BEGIN  
       SELECT @b_success = 1  
       WHILE @@TRANCOUNT > @n_starttcnt  
       BEGIN  
          COMMIT TRAN  
       END  
       RETURN  
    END
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_packing_list_144_rdt] TO nSQL 
GO