IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_BackendVoicePickRelease]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[isp_BackendVoicePickRelease]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_BackendVoicePickRelease                           */
/* Creation Date: 29-Jan-2021                                              */
/* Copyright: LFL                                                          */
/* Written by:  WLChooi                                                    */
/*                                                                         */
/* Purpose: WMS-16040 - CN Mast Backend Job for Voice Picking Notification */
/*                                                                         */
/* Called By: SQL Job                                                      */
/*                                                                         */
/* GitLab Version: 1.1                                                     */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/* 2021-04-12   WLChooi 1.1   WMS-16040 - Modify logic to cater for other  */
/*                            storers (WL01)                               */
/***************************************************************************/  
CREATE PROC [dbo].[isp_BackendVoicePickRelease]  
(     @c_Storerkey   NVARCHAR(15)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_Debug              INT
         , @n_Continue           INT 
         , @n_StartTCnt          INT 

   DECLARE @c_Loadkey         NVARCHAR(10)
         , @c_Facility        NVARCHAR(5)
         , @c_Orderkey        NVARCHAR(10)
         , @c_Pickslipno      NVARCHAR(10)
         , @c_TransmitLogKey  NVARCHAR(10)
         , @c_LoadLine        NVARCHAR(5)

   --WL01 S
   DECLARE @c_Code           NVARCHAR(100) = ''
         , @c_Short          NVARCHAR(100) = ''
         , @c_UDF01          NVARCHAR(100) = ''
         , @n_RowCount       INT = 0
   --WL01 E

       
   SET @b_Success= 1 
   SET @n_Err    = 0  
   SET @c_ErrMsg = ''
   SET @b_Debug = '0' 
   SET @n_Continue = 1  
   SET @n_StartTCnt = @@TRANCOUNT  
   
   CREATE TABLE #TMP_Data (
   	Loadkey       NVARCHAR(10) NULL,
   	TaskBatchNo   NVARCHAR(10) NULL 
   )

   IF (@n_continue = 1 OR @n_continue = 2) 
   BEGIN   
      DECLARE cur_Loadkey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT LP.Loadkey, LP.Facility
         FROM ORDERS OH (NOLOCK)
         JOIN LOADPLANDETAIL LPD (NOLOCK) ON OH.OrderKey = LPD.OrderKey
         JOIN LOADPLAN LP (NOLOCK) ON LP.LoadKey = LPD.LoadKey
         JOIN PACKTASK PT (NOLOCK) ON PT.Orderkey = OH.Orderkey
         WHERE OH.StorerKey = @c_Storerkey AND LP.[Status] < '5'
         AND LP.UserDefine10 = 'VP'
         AND LP.EditDate <= CONVERT(DATETIME, DATEADD(MINUTE, -2, GETDATE() ) , 120 )
      
      OPEN cur_Loadkey
      
      FETCH NEXT FROM cur_Loadkey INTO @c_Loadkey, @c_Facility
      
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         DECLARE cur_PackTask CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT PT.TaskBatchno
            FROM LOADPLANDETAIL LPD (NOLOCK)
            JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = LPD.OrderKey
            JOIN PACKTASK PT (NOLOCK) ON PT.Orderkey = OH.Orderkey
            WHERE LPD.LoadKey = @c_Loadkey
      
         OPEN cur_PackTask
         
         FETCH NEXT FROM cur_PackTask INTO @c_Pickslipno
         
         WHILE @@FETCH_STATUS <> -1
         BEGIN
            --WL01 S
            SET @c_Short = ''
            SET @c_UDF01 = ''
            SET @n_RowCount = 0

            SELECT TOP 1 @c_Short     = ISNULL(CL.Short,'')   --LocationCategory
                       , @c_UDF01     = ISNULL(CL.UDF01,'')   --LocationType
            FROM CODELKUP CL (NOLOCK)
            WHERE CL.LISTNAME = 'BlocLocCat' AND CL.Code = @c_Facility
            AND CL.Storerkey = @c_Storerkey

            --Multiple Orderkey may appear in 1 Pickslipno/TaskBatchno
            --If one of the orderkey can link with Codelkup, which mean do not generate Transmitlog2 for this Pickslipno
            SELECT @n_RowCount = COUNT(1)
            FROM PICKDETAIL PD (NOLOCK)
            JOIN LOC (NOLOCK) ON LOC.Loc = PD.Loc
            WHERE PD.PickSlipNo = @c_Pickslipno
            AND (LOC.LocationCategory IN (SELECT ColValue from dbo.fnc_delimsplit (',',@c_Short)) 
                  OR LOC.LocationType IN (SELECT ColValue from dbo.fnc_delimsplit (',',@c_UDF01)))
            
         	--IF EXISTS (SELECT 1
            --           FROM PICKDETAIL PD (NOLOCK)
            --           JOIN LOC LOC (NOLOCK) ON LOC.Loc = PD.Loc
            --           LEFT JOIN CODELKUP CL (NOLOCK) ON CL.LISTNAME = 'BlocLocCat' AND CL.Storerkey = PD.Storerkey
            --                                         AND CL.Code2 = @c_Facility  AND CL.Short = LOC.LocationCategory
            --           WHERE PD.PickSlipNo = @c_Pickslipno AND CL.Short IS NULL)
            IF @n_RowCount = 0
            BEGIN   --WL01 E
            	IF NOT EXISTS (SELECT 1 
            	               FROM LOADPLANDETAIL LPD (NOLOCK) 
            	               JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey = LPD.OrderKey
            	               WHERE PD.PickSlipNo = @c_Pickslipno AND UserDefine10 <> '')
      	      BEGIN
      	         INSERT INTO #TMP_Data (Loadkey, TaskBatchNo)
      	         SELECT @c_Loadkey, @c_Pickslipno
      	         
      	         --Insert Transmitlog2
      	         SELECT @b_success = 1
         
                  EXECUTE nspg_getkey      
                        'TransmitLogKey2'      
                        , 10      
                        , @c_TransmitLogKey OUTPUT      
                        , @b_success        OUTPUT      
                        , @n_err            OUTPUT      
                        , @c_errmsg         OUTPUT      
                  
                  IF NOT @b_success = 1      
                  BEGIN      
                     SET @n_continue = 3      
                     SET @n_err = 71800   -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
                     SET @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+': Unable to Obtain TransmitLogKey2. (isp_BackendVoicePickRelease)' + 
                                     ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '      
                     GOTO QUIT_SP  
                  END 
                  
                  INSERT INTO TRANSMITLOG2 (transmitlogkey, tablename, key1, key2, key3, transmitflag)
                  SELECT @c_TransmitLogKey, 'WSPICKVCLOG', @c_Pickslipno, @c_Loadkey, @c_Storerkey, '0'
                  
                  SELECT @n_err = @@ERROR  
                  
                  IF @n_err <> 0  
                  BEGIN
                     SELECT @n_continue = 3  
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=71805    
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                                      + ': Insert Failed On Table TRANSMITLOG2. (isp_BackendVoicePickRelease)'   
                                      + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
                  END 
                  
                  DECLARE cur_Orderkey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT DISTINCT PT.Orderkey
                     FROM PACKTASK PT (NOLOCK)
                     WHERE PT.TaskBatchNo = @c_Pickslipno
                  
                  OPEN cur_Orderkey
                  
                  FETCH NEXT FROM cur_Orderkey INTO @c_Orderkey
                  
                  WHILE @@FETCH_STATUS <> -1
                  BEGIN
                  	UPDATE LOADPLANDETAIL WITH (ROWLOCK)
                  	SET UserDefine10 = 'VP', TrafficCop =  NULL
                  	WHERE OrderKey = @c_Orderkey
                  	
                  	FETCH NEXT FROM cur_Orderkey INTO @c_Orderkey
                  END
                  CLOSE cur_Orderkey
                  DEALLOCATE cur_Orderkey 
                  
      	      END
            END
NEXT_PSNO:
            FETCH NEXT FROM cur_PackTask INTO @c_Pickslipno
         END
         CLOSE cur_PackTask
         DEALLOCATE cur_PackTask
         
         IF NOT EXISTS (SELECT 1 
            	         FROM LOADPLANDETAIL LPD (NOLOCK) 
            	         WHERE LPD.Loadkey = @c_Loadkey AND LPD.UserDefine10 <> 'VP')
         BEGIN
            UPDATE LoadPlan WITH (ROWLOCK)
            SET UserDefine10 = 'VPCFM', TrafficCop = NULL
            WHERE LoadKey = @c_Loadkey
         END
         
NEXT_LOAD:
         FETCH NEXT FROM cur_Loadkey INTO @c_Loadkey, @c_Facility
      END
   END
   
   --SELECT * FROM #TMP_DATA

QUIT_SP:
   IF OBJECT_ID('tempdb..#TMP_DATA') IS NOT NULL
      DROP TABLE #TMP_DATA
      
   IF CURSOR_STATUS('LOCAL', 'cur_Loadkey') IN (0 , 1)
   BEGIN
      CLOSE cur_Loadkey
      DEALLOCATE cur_Loadkey   
   END
   
   IF CURSOR_STATUS('LOCAL', 'cur_PackTask') IN (0 , 1)
   BEGIN
      CLOSE cur_PackTask
      DEALLOCATE cur_PackTask   
   END
   
   IF CURSOR_STATUS('LOCAL', 'cur_Orderkey') IN (0 , 1)
   BEGIN
      CLOSE cur_Orderkey
      DEALLOCATE cur_Orderkey   
   END

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_BackendVoicePickRelease'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
        COMMIT TRAN
      END 
      RETURN
   END 
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON [dbo].[isp_BackendVoicePickRelease] TO nSQL 
GO
