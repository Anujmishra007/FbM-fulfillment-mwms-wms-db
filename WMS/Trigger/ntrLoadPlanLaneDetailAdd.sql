SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Trigger: ntrLoadPlanLaneDetailAdd                                    */
/* Creation Date: 08-May-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLC015                                                   */
/*                                                                      */
/* Purpose: FCR-3778 - Copy LoadplanLaneDetail value to ORDERS          */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver.   Purposes                                */
/* 08-May-2025  WLC015   1.0    Created (FCR-3778)                      */
/************************************************************************/

CREATE OR ALTER TRIGGER [dbo].[ntrLoadPlanLaneDetailAdd]
ON [dbo].[LoadPlanLaneDetail]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF 
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success                     INT            -- Populated by calls to stored procedures - was the proc successful?
         , @n_Err                         INT            -- Error number returned by stored procedure or this trigger
         , @c_ErrMsg                      NVARCHAR(250)  -- Error message returned by stored procedure or this trigger
         , @n_Continue                    INT
         , @n_starttcnt                   INT            -- Holds the current transaction count
         , @c_AssignLaneUpdLocToOrd       NVARCHAR(30)   = N''
         , @c_AssignLaneUpdLocToOrd_Opt5  NVARCHAR(4000) = N''
         , @c_AssignLaneByOrder           NVARCHAR(10)   = N'N'
         , @c_StorerKey                   NVARCHAR(15)   = N''
         , @c_PrevStorerkey               NVARCHAR(15)   = N''
         , @c_Facility                    NVARCHAR(5)    = N''
         , @c_PrevFacility                NVARCHAR(5)    = N''
         , @c_CopyToOrders                NVARCHAR(1000) = N''
         , @c_Orderkey                    NVARCHAR(10)   = N''
         , @c_Loadkey                     NVARCHAR(10)   = N''
         , @c_ExternOrderkey              NVARCHAR(50)   = N''
         , @c_Loc                         NVARCHAR(10)   = N''
         , @c_SQL                         NVARCHAR(MAX)  = N''
         , @c_SQLParam                    NVARCHAR(MAX)  = N''
         , @c_ColValue                    NVARCHAR(100)  = N''
         , @c_DataType                    NVARCHAR(50)   = N''
         , @CUR_LOOP                      CURSOR              
         , @CUR_MAIN                      CURSOR              

   SELECT @n_Continue = 1, @n_starttcnt = @@TRANCOUNT

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_Continue = 4
   END

   IF (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SET @CUR_MAIN = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT O.Storerkey, O.Facility, I.ExternOrderKey, I.LOC, I.LoadKey
      FROM INSERTED I
      JOIN LOADPLANDETAIL L (NOLOCK) ON I.LoadKey = L.LoadKey
      JOIN ORDERS O (NOLOCK) ON O.OrderKey = L.OrderKey 
      WHERE O.[Status] < '9'
      ORDER BY O.Storerkey, O.Facility, I.LoadKey, I.ExternOrderKey, I.LOC
      
      OPEN @CUR_MAIN

      FETCH NEXT FROM @CUR_MAIN INTO @c_StorerKey, @c_Facility, @c_ExternOrderkey, @c_Loc, @c_Loadkey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF CONCAT(TRIM(@c_StorerKey), TRIM(@c_Facility)) <> 
            CONCAT(TRIM(@c_PrevStorerkey), TRIM(@c_PrevFacility))
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
            END
         END

         IF @c_AssignLaneUpdLocToOrd = '1' AND ISNULL(@c_CopyToOrders, '') <> ''
         BEGIN
            SET @c_Orderkey = ''

            SET @CUR_LOOP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT O.Orderkey
            FROM LOADPLANDETAIL LPD (NOLOCK)
            JOIN ORDERS O (NOLOCK) ON LPD.OrderKey = O.OrderKey
            WHERE LPD.LoadKey = @c_Loadkey
            AND O.[Status] < '9'
            AND O.Storerkey = @c_StorerKey
            AND O.ExternOrderkey = IIF(@c_AssignLaneByOrder = 'Y', @c_ExternOrderkey, O.ExternOrderkey)
            ORDER BY O.Orderkey

            OPEN @CUR_LOOP

            FETCH NEXT FROM @CUR_LOOP INTO @c_Orderkey
            
            WHILE @@FETCH_STATUS <> -1
            BEGIN
               EXEC sp_executesql @c_SQL
                                , @c_SQLParam
                                , @c_Orderkey
                                , @c_Loc

               FETCH NEXT FROM @CUR_LOOP INTO @c_Orderkey
            END
            CLOSE @CUR_LOOP
            DEALLOCATE @CUR_LOOP
         END

         SET @c_PrevStorerkey = @c_StorerKey
         SET @c_PrevFacility = @c_Facility
         
         FETCH NEXT FROM @CUR_MAIN INTO @c_StorerKey, @c_Facility, @c_ExternOrderkey, @c_Loc, @c_Loadkey
      END
      CLOSE @CUR_MAIN
      DEALLOCATE @CUR_MAIN
   END

   QUIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
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
      EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ntrLoadPlanLaneDetailAdd'
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR    -- SQL2012
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
GO