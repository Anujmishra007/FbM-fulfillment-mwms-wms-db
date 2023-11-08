SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: isp_RCM_WV_RemoveNonFullAllocOrd                   */
/* Creation Date:10-OCT-2023                                            */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-23858 WAVE RCM Remove Non-fully allocated orders        */
/*                                                                      */
/* Called By: WAVE Dymaic RCM configure at listname 'RCMConfig'         */
/*                                                                      */
/* Parameters:                                                          */
/*                                                                      */
/* PVCS Version: 1.0	                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 10-OCT-2023  NJOW      1.0   DEVOPS Combine Script                   */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[isp_RCM_WV_RemoveNonFullAllocOrd]
   @c_Wavekey  NVARCHAR(10),
   @b_success  int OUTPUT,
   @n_err      int OUTPUT,
   @c_errmsg   NVARCHAR(225) OUTPUT,
   @c_code     NVARCHAR(30)=''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue      INT,
           @n_cnt           INT,
           @n_starttcnt     INT,
           @c_Orderkey      NVARCHAR(10),
           @c_Status        NVARCHAR(10),
           @c_Pickdetailkey NVARCHAR(10)

   SELECT @n_Continue = 1, @b_success = 1, @n_starttcnt=@@TRANCOUNT, @c_errmsg='', @n_err=0

   IF @n_continue IN(1,2)
   BEGIN
      DECLARE CUR_WAVEORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT O.Orderkey, O.Status
         FROM WAVEDETAIL WD (NOLOCK)
         JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
         WHERE WD.Wavekey = @c_Wavekey
         AND O.Status < '2'
         ORDER BY O.Orderkey

      OPEN CUR_WAVEORD

      FETCH NEXT FROM CUR_WAVEORD INTO @c_Orderkey, @c_Status

      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2) 
      BEGIN
         IF @c_Status = '1'
         BEGIN
         	  DECLARE CUR_PICKDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         	     SELECT Pickdetailkey
         	     FROM PICKDETAIL (NOLOCK)
         	     WHERE Orderkey = @c_Orderkey
            
            OPEN CUR_PICKDET

            FETCH NEXT FROM CUR_PICKDET INTO @c_Pickdetailkey

            WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2) 
            BEGIN
            	 DELETE FROM PICKDETAIL
            	 WHERE Pickdetailkey = @c_Pickdetailkey

      	       IF @n_err <> 0
      	       BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 36100   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Delete Failed on Table PICKDETAIL. (isp_RCM_WV_RemoveNonFullAllocOrd)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
               END            	 
            	 
               FETCH NEXT FROM CUR_PICKDET INTO @c_Pickdetailkey            	
            END           
            CLOSE CUR_PICKDET
            DEALLOCATE CUR_PICKDET                      	              	     
         END
         
         DELETE FROM WAVEDETAIL 
         WHERE Wavekey = @c_Wavekey
         AND Orderkey = @c_Orderkey

      	 SET @n_err = @@ERROR

      	 IF @n_err <> 0
      	 BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 36110   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Delete Failed on Table WAVEDETAIL. (isp_RCM_WV_RemoveNonFullAllocOrd)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         END

         FETCH NEXT FROM CUR_WAVEORD INTO @c_Orderkey, @c_Status
      END
      CLOSE CUR_WAVEORD
      DEALLOCATE CUR_WAVEORD
   END

ENDPROC:

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
  	  execute nsp_logerror @n_err, @c_errmsg, 'isp_RCM_WV_RemoveNonFullAllocOrd'
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
END -- End PROC
GO
GRANT EXECUTE ON  [dbo].[isp_RCM_WV_RemoveNonFullAllocOrd] TO [NSQL]
GO
