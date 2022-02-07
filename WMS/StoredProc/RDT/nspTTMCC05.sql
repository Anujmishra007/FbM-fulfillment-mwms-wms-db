if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspTTMCC05]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspTTMCC05]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Stored Procedure: nspTTMCC05                                         */
/* Creation Date: 09-11-2011                                            */
/* Copyright: IDS                                                       */
/*                                                                      */
/* Purpose: Only allow 1 user to do cycle count in 1 aisle              */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 28-03-2018   James         WMS4083. Created                          */
/************************************************************************/

CREATE PROC    nspTTMCC05
@c_userid           NVARCHAR(18)
,              @c_areakey01        NVARCHAR(10)
,              @c_areakey02        NVARCHAR(10)
,              @c_areakey03        NVARCHAR(10)
,              @c_areakey04        NVARCHAR(10)
,              @c_areakey05        NVARCHAR(10)
,              @c_lastloc          NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_debug int
   SELECT @b_debug = 0
   DECLARE        @n_continue int        ,
   @n_starttcnt int        , -- Holds the current transaction count
   @n_cnt int              , -- Holds @@ROWCOUNT after certain operations
   @n_err2 int             , -- For Additional Error Detection
   @b_Success int          ,
   @n_err int              ,
   @c_errmsg NVARCHAR(250)
   SELECT @n_starttcnt=@@TRANCOUNT , @n_continue=1, @b_success=0,@n_err=0,@c_errmsg='',@n_err2=0
   DECLARE @c_executestmt NVARCHAR(255)
   DECLARE @c_LastLocAisle    NVARCHAR( 10)

   /* #INCLUDE <SPTMCC01_1.SQL> */
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SET @c_LastLocAisle = ''

      IF ISNULL( @c_areakey01, '') <> ''
      BEGIN
         SELECT TOP 1 @c_LastLocAisle = LOC.LocAisle 
         FROM dbo.TASKDETAIL TA WITH (NOLOCK)  
         JOIN dbo.LOC LOC WITH (NOLOCK) ON TA.FROMLOC = LOC.LOC
         WHERE  TA.Tasktype = 'CC'  
               AND TA.Status = '9'  
               AND ta.UserKey = @c_UserID  
               AND NOT EXISTS(  
                       SELECT 1  
                       FROM   TaskManagerSkipTasks(NOLOCK)  
                       WHERE  TaskManagerSkipTasks.Taskdetailkey = TA.TaskDetailkey  
                   )  
         ORDER BY  
               TA.EditDate DESC   

         IF ISNULL( @c_LastLocAisle, '') <> ''
         BEGIN
            IF NOT EXISTS ( SELECT 1 FROM dbo.AreaDetail AD WITH (NOLOCK)
                            JOIN dbo.LOC LOC WITH (NOLOCK) ON AD.PutAwayZone = LOC.PutAwayZone
                            WHERE AD.AreaKey = @c_areakey01
                            AND   LOC.LocAisle = @c_LastLocAisle)
            BEGIN
               SET @c_LastLocAisle = ''
            END
         END
      END

      IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_areakey01)) IS NULL
      BEGIN
         DECLARE cursor_CCTASKCANDIDATES
         CURSOR FOR
         SELECT TaskDetailKey
         --FROM TaskDetail,TaskManagerUserDetail,AreaDetail,Loc -- (ChewKP01)
         FROM TaskDetail TaskDetail WITH (NOLOCK)                 -- (ChewKP01)  
         JOIN Loc Loc WITH (NOLOCK) ON (TaskDetail.FromLoc = Loc.Loc) -- (ChewKP01)
         JOIN AreaDetail AreaDetail WITH (NOLOCK) ON (AreaDetail.PutAwayZone = LOC.PutAwayZone) -- (ChewKP01)
         JOIN TaskManagerUserDetail TaskManagerUserDetail WITH (NOLOCK) ON (TaskManagerUserDetail.AreaKey = AreaDetail.AreaKey) -- (ChewKP01)
         WHERE TaskDetail.Status = '0'
         AND TaskDetail.TaskType = 'CC'
         AND TaskDetail.UserKey = ''
         AND TaskManagerUserDetail.UserKey = @c_userid
         AND TaskManagerUserDetail.PermissionType = 'CC'
         AND TaskManagerUserDetail.Permission = '1'
         AND TaskManagerUserDetail.AreaKey = AreaDetail.AreaKey
         AND AreaDetail.Putawayzone = Loc.PutAwayZone
         AND TaskDetail.FromLoc = Loc.Loc
         AND NOT EXISTS ( SELECT 1 FROM dbo.TaskDetail TD2 WITH (NOLOCK) 
                          JOIN dbo.Loc Loc2 WITH (NOLOCK) ON (TD2.FromLoc = Loc2.Loc)
                          WHERE TD2.TaskType = 'CC'
                          AND   TD2.Status = '3'
                          AND   Loc.LocAisle = Loc2.LocAisle)
         ORDER BY Priority,TaskDetailKey
      END
   ELSE
      BEGIN
         DECLARE cursor_CCTASKCANDIDATES
         CURSOR FOR
         SELECT TaskDetailKey
         --FROM TaskDetail,AreaDetail,Loc
         FROM TaskDetail TaskDetail WITH (NOLOCK)                 -- (ChewKP01)  
         JOIN Loc Loc WITH (NOLOCK) ON (TaskDetail.FromLoc = Loc.Loc) -- (ChewKP01)
         JOIN AreaDetail AreaDetail WITH (NOLOCK) ON (AreaDetail.PutAwayZone = LOC.PutAwayZone) -- (ChewKP01)
         WHERE TaskDetail.Status = '0'
         AND TaskDetail.TaskType = 'CC'
         AND TaskDetail.UserKey = ''
         AND AreaDetail.AreaKey = @c_areakey01
         AND AreaDetail.Putawayzone = Loc.PutAwayZone
         AND TaskDetail.FromLoc = Loc.Loc
         AND NOT EXISTS ( SELECT 1 FROM dbo.TaskDetail TD2 WITH (NOLOCK) 
                          JOIN dbo.Loc Loc2 WITH (NOLOCK) ON (TD2.FromLoc = Loc2.Loc)
                          WHERE TD2.TaskType = 'CC'
                          AND   TD2.Status = '3'
                          AND   Loc.LocAisle = Loc2.LocAisle)
         AND ( ISNULL( @c_LastLocAisle, '') = '') OR ( Loc.LocAisle = ISNULL( @c_LastLocAisle, ''))
         ORDER BY Priority,TaskDetailKey
      END
      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err=79801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Execute Of CrossDock Tasks Pick Code Failed. (nspTTMCC05)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END
   /* #INCLUDE <SPTMCC01_2.SQL> */
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
      execute nsp_logerror @n_err, @c_errmsg, 'nspTTMCC05'
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
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nspTTMCC05 to nSQL
GO
