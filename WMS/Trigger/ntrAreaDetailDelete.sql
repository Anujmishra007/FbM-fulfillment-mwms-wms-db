if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrAreaDetailDelete]') 
              and OBJECTPROPERTY(id, N'IsTrigger') = 1) 
drop trigger [dbo].[ntrAreaDetailDelete]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************************/
/* Trigger: ntrAreaDetailDelete                                                        */
/* Creation Date:                                                                      */
/* Copyright: IDS                                                                      */
/* Written by:                                                                         */
/*                                                                                     */
/* Purpose: AreaDetail Table Delete Trigger                                            */
/*                                                                                     */
/* Called By:                                                                          */
/*                                                                                     */
/* PVCS Version: 1.2                                                                   */
/*                                                                                     */
/* Version: 5.4.2                                                                      */
/*                                                                                     */
/* Data Modifications:                                                                 */
/*                                                                                     */
/* Updates:                                                                            */
/* Date         Author  Ver   Purposes                                                 */
/* 09-08-2011   TLTING  1.1   Bug fix on validate check (tlting01)                     */
/***************************************************************************************/

CREATE TRIGGER [dbo].[ntrAreaDetailDelete]
 ON [dbo].[AreaDetail]
 FOR DELETE
 AS
 BEGIN
 IF @@ROWCOUNT = 0
 BEGIN
 RETURN
 END    
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
      /* #INCLUDE <TRAD1.SQL> */     
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT 1									-- area reference by PutawayStrategyDetail 
 FROM PutawayStrategyDetail with (NOLOCK), Deleted
 WHERE PutawayStrategyDetail.AreaTypeExclude01 = Deleted.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude02 = Deleted.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude03 = Deleted.AreaKey)
 AND NOT EXISTS(SELECT 1							-- no reference after delete -- tlting01
 FROM PutawayStrategyDetail with (NOLOCK), AreaDetail with (NOLOCK),Deleted
 WHERE NOT EXISTS( SELECT 1 from Deleted
		 WHERE Deleted.AreaKey = AreaDetail.AreaKey
		 AND Deleted.PutawayZone = AreaDetail.PutawayZone ) 
 AND ( PutawayStrategyDetail.AreaTypeExclude01 = AreaDetail.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude02 = AreaDetail.AreaKey
 OR PutawayStrategyDetail.AreaTypeExclude03 = AreaDetail.AreaKey) )
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 85900
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Putaway Strategy Details Still Reference Area. (ntrAreaDetailDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT 1								-- area reference by TaskManagerUserDetail 
 FROM TaskManagerUserDetail with (NOLOCK), Deleted
 WHERE TaskManagerUserDetail.AreaKey = Deleted.AreaKey)
 AND NOT EXISTS(SELECT 1						-- no reference after delete -- tlting01
 FROM AreaDetail with (NOLOCK),TaskManagerUserDetail with (NOLOCK), Deleted D2 
 WHERE NOT EXISTS( SELECT 1 from Deleted
		 WHERE Deleted.AreaKey = AreaDetail.AreaKey
		 AND Deleted.PutawayZone = AreaDetail.PutawayZone ) 
 AND AreaDetail.AreaKey = D2.AreaKey 
 AND TaskManagerUserDetail.AreaKey = AreaDetail.AreaKey)
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 85901
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On AreaDetail Failed As Task manager User Details Still Reference Area. (ntrAreaDetailDelete)"
 END
 END
      /* #INCLUDE <TRAD2.SQL> */
 IF @n_continue=3  -- Error Occured - Process And Return
 BEGIN
 IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrAreaDetailDelete"
 RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
 RETURN
 END
 ELSE
 BEGIN
 WHILE @@TRANCOUNT > @n_starttcnt
 BEGIN
 COMMIT TRAN
 END
 RETURN
 END
 END

