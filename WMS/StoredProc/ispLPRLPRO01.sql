IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ispLPRLPRO01]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[ispLPRLPRO01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* SP: ispLPRLPRO01                                                     */
/* Creation Date: 15-SEP-2021                                           */
/* Copyright: LFL                                                       */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-17958 - [CN] MAST VS Add New RCM & SP for Auto-Sorting  */ 
/*          Machines Trigger                                            */
/*                                                                      */
/* Usage:   Storerconfig LoadReleaseToProcess_SP = ispLPRLPRO?? to      */
/*          enable release Load to process option                       */
/*                                                                      */
/* Called By: isp_LoadReleaseToProcess_Wrapper                          */
/*                                                                      */
/* GitLab Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 15-Sep-2021  WLChooi  1.0  DevOps Combine Script                     */
/************************************************************************/

CREATE PROC [dbo].[ispLPRLPRO01] 
   @c_Loadkey  NVARCHAR(10),
   @c_CallFrom NVARCHAR(50),    --BuildLoad / ManualLoad
   @b_Success  INT OUTPUT,
   @n_err      INT OUTPUT,
   @c_errmsg   NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue       INT
         , @b_debug          INT
         , @n_StartTranCnt   INT
         , @c_Storerkey      NVARCHAR(15)
         , @c_TableName      NVARCHAR(15)
         , @c_Orderkey       NVARCHAR(10)
         , @c_PickslipNo     NVARCHAR(10)
         , @c_Facility       NVARCHAR(5)
         , @c_OrderStatus    NVARCHAR(1)
         , @c_DocType        NVARCHAR(1)
         , @c_trmlogkey      NVARCHAR(10)
         , @c_TransmitBatch  NVARCHAR(50) = ''

   IF @n_err = 1
      SET @b_debug = 1
      
   SELECT @n_StartTranCnt = @@TRANCOUNT, @n_continue = 1, @b_success = 1, @n_err = 0, @c_errmsg = ''

   -----Get Load Info-----
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN      
       SELECT @c_OrderStatus = MIN(ORDERS.[STATUS])
            , @c_DocType     = MIN(ORDERS.Doctype)
       FROM LOADPLANDETAIL (NOLOCK)
       JOIN ORDERS (NOLOCK) ON LOADPLANDETAIL.Orderkey = ORDERS.Orderkey        
       WHERE LOADPLANDETAIL.LoadKey = @c_Loadkey                  
   END
  
   ------Validation--------
   IF @n_continue=1 or @n_continue=2  
   BEGIN          
      IF @c_OrderStatus < '1'
      BEGIN
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 68025   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Release Failed. Some of the orders are not fully allocated. (ispLPRLPRO01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '           
         GOTO RETURN_SP
      END                                   
   END

   ------Insert Into Transmitlog2-------   
   IF (@n_continue = 1 or @n_continue = 2)
   BEGIN
      IF @c_DocType = 'N'
      BEGIN
         SET @c_TableName = 'WSRCSWVB2B'

         DECLARE cur_LOADORDER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT DISTINCT OH.Storerkey, OH.Loadkey, PH.PickHeaderkey
         FROM LOADPLANDETAIL LPD (NOLOCK)
         JOIN ORDERS OH (NOLOCK) ON LPD.Orderkey = OH.Orderkey
         JOIN PICKHEADER PH (NOLOCK) ON OH.Orderkey = PH.Orderkey
         JOIN CODELKUP CL (NOLOCK) ON CL.LISTNAME = 'WSRCSWVCON' AND CL.Short = '1'
                                  AND CL.Long  = OH.Facility
                                  AND CL.UDF01 = OH.DocType
                                  AND CL.UDF02 = ISNULL(OH.ECOM_SINGLE_Flag,'')
                                  AND CL.UDF03 = OH.[Status]
         WHERE LPD.LoadKey = @c_Loadkey
      END
      ELSE IF @c_DocType = 'E'
      BEGIN
         SET @c_TableName = 'WSRCSWVB2C'

         DECLARE cur_LOADORDER CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT DISTINCT OH.Storerkey, OH.Loadkey, PD.PickSlipNo
         FROM LOADPLANDETAIL LPD (NOLOCK)
         JOIN ORDERS OH (NOLOCK) ON LPD.Orderkey = OH.Orderkey
         JOIN PICKDETAIL PD (NOLOCK) ON OH.Orderkey = PD.Orderkey
         JOIN CODELKUP CL (NOLOCK) ON CL.LISTNAME = 'WSRCSWVCON' AND CL.Short = '1'
                                  AND CL.Long  = OH.Facility
                                  AND CL.UDF01 = OH.DocType
                                  AND CL.UDF02 = ISNULL(OH.ECOM_SINGLE_Flag,'')
                                  AND CL.UDF03 = OH.[Status]
         WHERE LPD.LoadKey = @c_Loadkey
      END
      ELSE
      BEGIN
         GOTO RETURN_SP 
      END

      OPEN cur_LOADORDER  
      FETCH NEXT FROM cur_LOADORDER INTO @c_Storerkey, @c_Loadkey, @c_Pickslipno      
      
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2) 
      BEGIN   
         SELECT @b_success = 1
         
         IF (@n_continue = 1 OR @n_continue = 2)
         BEGIN
            SELECT @b_success = 1
            EXECUTE nspg_getkey
            'TransmitlogKey2'
            , 10
            , @c_trmlogkey OUTPUT
            , @b_success   OUTPUT
            , @n_err       OUTPUT
            , @c_errmsg    OUTPUT
         
            IF NOT @b_success = 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err) 
                                + ': Unable to Obtain transmitlogkey. (ispLPRLPRO01) ( SQLSvr MESSAGE=' 
                                + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
               GOTO RETURN_SP 
            END
            ELSE 
            BEGIN
               IF (@n_continue = 1 OR @n_continue = 2)
               BEGIN
                  INSERT INTO Transmitlog2 (transmitlogkey, tablename, key1, key2, key3, transmitflag, TransmitBatch)
                  VALUES (@c_trmlogkey, @c_TableName, @c_Pickslipno, @c_Loadkey, @c_Storerkey, '0', @c_TransmitBatch)

                  SELECT @n_err = @@ERROR

                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3  
                     SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 68035   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                     SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert into TRANSMITLOG2 Failed. (ispLPRLPRO01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
                     GOTO RETURN_SP 
                  END
               END
            END
         END
                   
         /*EXEC ispGenTransmitLog2 @c_TableName, @c_Pickslipno, @c_Loadkey, @c_StorerKey, ''    
            , @b_success OUTPUT    
            , @n_err OUTPUT    
            , @c_errmsg OUTPUT
         
         IF @b_success <> 1    
         BEGIN
             SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 68030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
             SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert into TRANSMITLOG2 Failed. (ispLPRLPRO01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
             GOTO RETURN_SP 
         END*/   

         UPDATE dbo.LoadPlan
         SET UserDefine05 = 'Minions'
         WHERE LoadKey = @c_Loadkey

         IF @@ERROR <> 0 
         BEGIN
             SELECT @n_continue = 3  
             SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 68040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
             SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': UPDATE Loadplan Failed. (ispLPRLPRO01)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
             GOTO RETURN_SP 
         END

         FETCH NEXT FROM cur_LOADORDER INTO @c_Storerkey, @c_Loadkey, @c_Pickslipno    
      END
      CLOSE cur_LOADORDER  
      DEALLOCATE cur_LOADORDER                                   
   END  

RETURN_SP:
   IF ISNULL(@c_errmsg,'') = ''
      SET @c_errmsg = 'Auto-Sorting API record generated successfully.'

   IF (SELECT CURSOR_STATUS('LOCAL','cur_LOADORDER')) >=0 
   BEGIN
      CLOSE cur_LOADORDER           
      DEALLOCATE cur_LOADORDER      
   END  

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTranCnt
         BEGIN
            COMMIT TRAN
         END
      END
      execute nsp_logerror @n_err, @c_errmsg, 'ispLPRLPRO01'
      --RAISERROR @n_err @c_errmsg
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[ispLPRLPRO01] TO nSQL 
GO

