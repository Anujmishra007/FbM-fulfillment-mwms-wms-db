SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Trigger: ntrLoadPlanLaneDetailUpdate                                 */
/* Creation Date: 28-Oct-2013                                           */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Github Version: 1.1                                                  */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver.   Purposes                                */
/* 28-Oct-2013  TLTING   1.0    Review Editdate column update           */
/* 08-May-2025  WLC015   1.1    FCR-3778 AssignLaneUpdLocToOrd - Update */
/*                              Loc to ORDERS table (WL01)              */
/* 06-Oct-2025  AK01     1.2    UWP-42143 - Replace SUSER_SNAME with fnc_GetUserName */
/************************************************************************/
CREATE OR ALTER TRIGGER [dbo].[ntrLoadPlanLaneDetailUpdate]
ON [dbo].[LoadPlanLaneDetail]
FOR UPDATE
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

   DECLARE @b_Success    INT -- Populated by calls to stored procedures - was the proc successful?
         , @n_err        INT -- Error number returned by stored procedure or this trigger
         , @n_err2       INT -- For Additional Error Detection
         , @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue   INT
         , @n_starttcnt  INT -- Holds the current transaction count
         , @c_preprocess NVARCHAR(250) -- preprocess
         , @c_pstprocess NVARCHAR(250) -- post process
         , @n_cnt        INT
         , @c_AssignLaneUpdLocToOrd       NVARCHAR(30)   = N''    --WL01
         , @c_AssignLaneUpdLocToOrd_Opt5  NVARCHAR(4000) = N''    --WL01
         , @c_AssignLaneByOrder           NVARCHAR(10)   = N'N'   --WL01
         , @c_StorerKey                   NVARCHAR(15)   = N''    --WL01
         , @c_Facility                    NVARCHAR(5)    = N''    --WL01
         , @c_CopyToOrders                NVARCHAR(1000) = N''    --WL01
         , @c_Orderkey                    NVARCHAR(10)   = N''    --WL01
         , @c_Loc                         NVARCHAR(10)   = N''    --WL01
         , @c_SQL                         NVARCHAR(MAX)  = N''    --WL01
         , @c_SQLParam                    NVARCHAR(MAX)  = N''    --WL01
         , @c_ColValue                    NVARCHAR(100)  = N''    --WL01
         , @c_DataType                    NVARCHAR(50)   = N''    --WL01
         , @CUR_LOOP                      CURSOR                  --WL01
         , @CUR_MAIN                      CURSOR                  --WL01

   SELECT @n_continue = 1
        , @n_starttcnt = @@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END
   /* #INCLUDE <TRMBODU1.SQL> */

   IF (@n_continue = 1 OR @n_continue = 2) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE LoadPlanLaneDetail WITH (ROWLOCK)
      SET EditDate = dbo.fnc_GetDate()
        , EditWho = dbo.fnc_GetUserName()
        , TrafficCop = NULL
      FROM LoadPlanLaneDetail
         , INSERTED
      WHERE LoadPlanLaneDetail.LoadKey = INSERTED.LoadKey
      AND   LoadPlanLaneDetail.ExternOrderKey = INSERTED.ExternOrderKey
      AND   LoadPlanLaneDetail.ConsigneeKey = INSERTED.ConsigneeKey
      AND   LoadPlanLaneDetail.LP_LaneNumber = INSERTED.LP_LaneNumber

      SELECT @n_err = @@ERROR
           , @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250), @n_err)
              , @n_err = 73102 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg = N'NSQL' + CONVERT(CHAR(5), @n_err)
                            + N': Update Failed On Table LoadPlanLaneDetail. (ntrLoadPlanLaneDetailUpdate)' + N' ( '
                            + N' SQLSvr MESSAGE=' + dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_errmsg)) + N' ) '
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END

   --WL01 S
   IF (@n_Continue = 1 OR @n_Continue = 2)        
   BEGIN   	  
      IF EXISTS ( SELECT 1 FROM INSERTED I   ----->Put INSERTED if INSERT action
                  JOIN LoadPlanDetail LPD WITH (NOLOCK) ON I.LoadKey = LPD.LoadKey
                                                       AND I.ExternOrderKey = LPD.ExternOrderKey
                                                       AND I.ConsigneeKey = LPD.ConsigneeKey
                  JOIN ORDERS O (NOLOCK) ON LPD.OrderKey = O.OrderKey
                  JOIN storerconfig s WITH (NOLOCK) ON o.storerkey = s.storerkey    
                  JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
                  WHERE s.configkey = 'LoadPlanLaneDetailTrigger_SP' )   -----> Current table trigger storerconfig
      BEGIN        	  
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED
          
         SELECT * 
         INTO #INSERTED
         FROM INSERTED
                 
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
          
         SELECT * 
         INTO #DELETED
         FROM DELETED
          
         EXECUTE dbo.isp_LoadPlanLaneDetailTrigger_Wrapper
                  'UPDATE'  -----> @c_Action can be INSERT, UPDATE, DELETE
               , @b_Success  OUTPUT  
               , @n_Err      OUTPUT   
               , @c_ErrMsg   OUTPUT  
          
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3  
                  ,@c_errmsg = 'ntrLoadPlanLaneDetailUpdate ' + TRIM(ISNULL(@c_errmsg,''))
         END
                
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED
          
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
      END
   END

   IF (@n_Continue = 1 OR @n_Continue = 2) AND UPDATE(Loc)
   BEGIN
      SET @CUR_MAIN = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT O.Storerkey, O.Facility
      FROM INSERTED I
      JOIN DELETED D ON I.LoadKey = D.LoadKey
                    AND I.ExternOrderKey = D.ExternOrderKey
                    AND I.ConsigneeKey = D.ConsigneeKey
                    AND I.LP_LaneNumber = D.LP_LaneNumber
                    AND I.MBOLKey = D.MBOLKey
                    AND I.LOC <> D.LOC
      JOIN LOADPLANDETAIL LPD (NOLOCK) ON I.LoadKey = LPD.LoadKey
                                      AND I.ExternOrderKey = LPD.ExternOrderKey
                                      AND I.ConsigneeKey = LPD.ConsigneeKey
      JOIN ORDERS O (NOLOCK) ON O.OrderKey = LPD.OrderKey 
      WHERE O.[Status] < '9'
      ORDER BY O.Storerkey, O.Facility
      
      OPEN @CUR_MAIN

      FETCH NEXT FROM @CUR_MAIN INTO @c_StorerKey, @c_Facility

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @c_CopyToOrders = N''
         SET @c_AssignLaneUpdLocToOrd = N''
         SET @c_AssignLaneUpdLocToOrd_Opt5 = N''
         
         SELECT @c_AssignLaneUpdLocToOrd = fgr.Authority
              , @c_AssignLaneUpdLocToOrd_Opt5 = fgr.Option5
         FROM dbo.fnc_GetRight2 (@c_Facility, @c_StorerKey, '', 'AssignLaneUpdLocToOrd') fgr
         
         SELECT @c_CopyToOrders = dbo.fnc_GetParamValueFromString('@c_CopyToOrders'
                                                                , @c_AssignLaneUpdLocToOrd_Opt5
                                                                , @c_CopyToOrders) 

         SELECT @c_AssignLaneByOrder = dbo.fnc_GetParamValueFromString('@c_AssignLaneByOrder'
                                                                     , @c_AssignLaneUpdLocToOrd_Opt5
                                                                     , @c_AssignLaneByOrder) 
         
         IF @c_AssignLaneUpdLocToOrd = '1' AND ISNULL(@c_CopyToOrders, '') <> ''
         BEGIN
            SET @c_CopyToOrders = REPLACE(@c_CopyToOrders, ' ', '')
            SET @c_SQL = ''
            SET @c_SQLParam = ''
         
            --Check Column exists
            IF (@n_Continue = 1 OR @n_Continue = 2)
            BEGIN
               SET @CUR_LOOP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT TRIM([value])
               FROM STRING_SPLIT(@c_CopyToOrders, ',')
            
               OPEN @CUR_LOOP
            
               FETCH NEXT FROM @CUR_LOOP INTO @c_ColValue
            
               WHILE @@FETCH_STATUS <> -1
               BEGIN
                  SET @c_DataType = ''
         
                  SELECT @c_DataType = DATA_TYPE
                  FROM INFORMATION_SCHEMA.COLUMNS
                  WHERE TABLE_NAME = 'ORDERS'
                  AND COLUMN_NAME = @c_ColValue
         
                  IF @c_ColValue IN ( 'EditWho', 'EditDate', 'AddWho', 'AddDate'
                                    , 'ArchiveCop', 'TrafficCop', 'TimeStamp')
                  OR @c_DataType NOT LIKE '%char%'
                  BEGIN
                     GOTO NEXT_LOOP
                  END
         
                  IF @c_DataType = ''
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 60530
                     SELECT @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Column: ' + @c_ColValue 
                                      + ' is not valid in ORDERS table. (ntrLoadPlanLaneDetailAdd)' 
                                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '   	   	
                     GOTO QUIT_SP 
                  END
                  ELSE
                  BEGIN
                     SET @c_SQL += CONCAT(', ', @c_ColValue, ' = ', '@c_Loc')
                  END
         
                  NEXT_LOOP:
                  FETCH NEXT FROM @CUR_LOOP INTO @c_ColValue
               END
               CLOSE @CUR_LOOP
               DEALLOCATE @CUR_LOOP
            END

            --Build dynamic SQL for UPDATE statement
            SET @c_SQL = N' UPDATE ORDERS ' + CHAR(13)
                       + N' SET TrafficCop = NULL' + @c_SQL  + CHAR(13)
                       + N' WHERE Orderkey = @c_Orderkey '
            
            SET @c_SQLParam = N' @c_Orderkey NVARCHAR(10), @c_Loc NVARCHAR(10) '
            SET @c_Orderkey = ''

            IF @c_AssignLaneByOrder = 'Y'
            BEGIN
               SET @CUR_LOOP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT DISTINCT O.OrderKey, I.LOC
               FROM INSERTED I
               JOIN DELETED D ON I.LoadKey = D.LoadKey
                             AND I.ExternOrderKey = D.ExternOrderKey
                             AND I.ConsigneeKey = D.ConsigneeKey
                             AND I.LP_LaneNumber = D.LP_LaneNumber
                             AND I.MBOLKey = D.MBOLKey
                             AND I.LOC <> D.LOC
               JOIN LOADPLANDETAIL LPD (NOLOCK) ON I.LoadKey = LPD.LoadKey
                                               AND I.ExternOrderKey = LPD.ExternOrderKey
                                               AND I.ConsigneeKey = LPD.ConsigneeKey
               JOIN ORDERS O (NOLOCK) ON O.OrderKey = LPD.OrderKey 
               WHERE O.[Status] < '9'
               AND O.StorerKey = @c_StorerKey
               AND O.Facility = @c_Facility
            END
            ELSE
            BEGIN
               SET @CUR_LOOP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT DISTINCT O.OrderKey, I.LOC
               FROM INSERTED I
               JOIN DELETED D ON I.LoadKey = D.LoadKey
                             AND I.ExternOrderKey = D.ExternOrderKey
                             AND I.ConsigneeKey = D.ConsigneeKey
                             AND I.LP_LaneNumber = D.LP_LaneNumber
                             AND I.MBOLKey = D.MBOLKey
                             AND I.LOC <> D.LOC
               JOIN LOADPLANDETAIL LPD (NOLOCK) ON I.LoadKey = LPD.LoadKey
               JOIN ORDERS O (NOLOCK) ON O.OrderKey = LPD.OrderKey 
               WHERE O.[Status] < '9'
               AND O.StorerKey = @c_StorerKey
               AND O.Facility = @c_Facility
            END

            OPEN @CUR_LOOP

            FETCH NEXT FROM @CUR_LOOP INTO @c_Orderkey, @c_Loc
            
            WHILE @@FETCH_STATUS <> -1
            BEGIN
               EXEC sp_executesql @c_SQL
                                , @c_SQLParam
                                , @c_Orderkey
                                , @c_Loc

               FETCH NEXT FROM @CUR_LOOP INTO @c_Orderkey, @c_Loc
            END
            CLOSE @CUR_LOOP
            DEALLOCATE @CUR_LOOP
         END

         FETCH NEXT FROM @CUR_MAIN INTO @c_StorerKey, @c_Facility
      END
      CLOSE @CUR_MAIN
      DEALLOCATE @CUR_MAIN
   END

   QUIT_SP:
   --WL01 E

   /* #INCLUDE <TRMBODU2.SQL> */
   IF @n_continue = 3 -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrLoadPlanLaneDetailUpdate'
      RAISERROR(@c_errmsg, 16, 1) WITH SETERROR -- SQL2012 
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
