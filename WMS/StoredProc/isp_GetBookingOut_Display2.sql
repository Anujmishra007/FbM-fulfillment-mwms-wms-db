IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetBookingOut_Display2]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetBookingOut_Display2]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_GetBookingOut_Display2                              */
/* Creation Date: 01-FEB-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose: WMS-918 - WMS Door Booking Dashboard Enhancement            */
/*        :                                                             */
/* Called By: d_dw_booking_dashboard_out_dsp2                           */
/*          :                                                           */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 14-MAR-2017 Wan01    1.1   Fixed Order_Status                        */  
/* 22-MAR-2017 TLTING   1.1   foce Commit tran -                        */
/************************************************************************/
CREATE PROC [dbo].[isp_GetBookingOut_Display2]
      (  @c_Facility          NVARCHAR(5)
      ,  @c_Storerkey         NVARCHAR(15)
      ,  @c_Door              NVARCHAR(10)
      ,  @dt_StartLoadDate    DATETIME
      ,  @dt_EndLoadDate      DATETIME
      )
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE  @c_SQL         NVARCHAR(MAX)
         ,  @c_SQLWhere    NVARCHAR(MAX)
         ,  @c_SQLSTR      NVARCHAR(MAX)
         ,  @c_STRWhere    NVARCHAR(MAX)

         ,  @n_TotalCnt    INT
         ,  @n_RecToIns    INT
         ,  @n_RowPerPage  INT
         ,  @n_starttcnt   INT

   SET @n_starttcnt=@@TRANCOUNT

   SET @n_RowPerPage = 20

   CREATE TABLE #TMP_DSP2
      (  RowNo                INT            IDENTITY(1,1)  NOT NULL PRIMARY KEY
      ,  Facility             NVARCHAR(5)    NULL
      ,  Storerkey            NVARCHAR(15)   NULL
      ,  BookingNo            INT            NULL
      ,  BookingDate          DATETIME       NULL
      ,  EndTime              DATETIME       NULL
      ,  Loc                  NVARCHAR(10)   NULL
      ,  ToLoc                NVARCHAR(10)   NULL
      ,  Loc2                 NVARCHAR(10)   NULL
      ,  VehicleType          NVARCHAR(10)   NULL
      ,  Truck_Name           NVARCHAR(38)   NULL
      ,  Truck_Status         NVARCHAR(20)   NULL
      ,  Order_Status         NVARCHAR(20)   NULL
      ,  Order_Status_Color   INT            NULL
      ,  Remarks              NVARCHAR(30)   NULL
      ,  BKO_Status           NVARCHAR(10)   NULL
      )


   IF ISNULL(RTRIM(@c_Facility),'') = ''
   BEGIN
      GOTO QUIT_SP
   END

   SET @c_SQLWhere = N' WHERE BKO.Facility = N''' + RTRIM(@c_Facility) + ''''
   SET @c_STRWhere = ''

   IF ISNULL(RTRIM(@c_Storerkey),'') <> ''
   BEGIN
      SET @c_STRWhere = @c_STRWhere + N' AND Storerkey = N''' + RTRIM(@c_Storerkey) + ''''
   END

   IF ISNULL(RTRIM(@c_Door),'') <> ''
   BEGIN
      SET @c_SQLWhere = @c_SQLWhere 
                      + N' AND EXISTS ( SELECT 1'
                      +              ' FROM dbo.fnc_GetBookingDoor(BKO.Facility, BKO.Loc, BKO.ToLoc, BKO.Loc2, ''O'') DOOR'
                      +              ' WHERE DOOR.Loc = N''' +  RTRIM(@c_Door) + ''' )'
   END

   IF ISNULL(@dt_StartLoadDate,'1900-01-01') <> '1900-01-01'
   BEGIN
      SET @c_SQLWhere =  @c_SQLWhere 
                      + N' AND BKO.BookingDate >= N''' + CONVERT(NVARCHAR(20), @dt_StartLoadDate, 120) + ''''
   END

   IF ISNULL(@dt_EndLoadDate,'1900-01-01') <> '1900-01-01'
   BEGIN
      SET @c_SQLWhere =  @c_SQLWhere 
                      + N' AND BKO.EndTime <= N''' + CONVERT(NVARCHAR(20), @dt_EndLoadDate, 120) + ''''
   END
  
   SET @c_SQLWhere = @c_SQLWhere + N' AND (BKO.Status <> ''9'' OR LP.Status <> ''9'')'

   --START
   SET @c_SQLSTR = N'DECLARE CUR_STR CURSOR FAST_FORWARD READ_ONLY FOR'
                 + ' SELECT RTRIM(STORER.Storerkey)'
                 + ' FROM   STORER WITH (NOLOCK)'
                 + ' WHERE  STORER.Type = ''1'''
                 + @c_STRWhere 
                 + ' ORDER BY STORER.SUSR2'

   EXEC (@c_SQLSTR)

   OPEN CUR_STR

   FETCH NEXT FROM CUR_STR INTO @c_Storerkey
   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @c_SQL = N'SELECT DISTINCT'
                + '  BKO.Facility'
                + ' ,Storerkey = RTRIM(OH.Storerkey)'
                + ' ,BKO.BookingNo'
                + ' ,BKO.BookingDate'
                + ' ,BKO.EndTime'
                + ' ,Loc  = ISNULL(RTRIM(BKO.Loc),'''')'
                + ' ,ToLoc= ISNULL(RTRIM(BKO.ToLoc),'''')'
                + ' ,Loc2 = ISNULL(RTRIM(BKO.Loc2),'''')'
                + ' ,VehicleType= ISNULL(RTRIM(BKO.VehicleType),'''')'
                + ' ,Truck_Name = ISNULL(RTRIM(BKO.LicenseNo),'''') + ''/''+ ISNULL(RTRIM(BKO.Carrierkey),'''')'
                + ' ,Truck_Status = CASE WHEN BKO.Status = ''0'' THEN ''Normal'''
                +                      ' WHEN BKO.Status = ''1'' THEN ''Arrived'''
                +                      ' WHEN BKO.Status = ''2'' THEN ''Loading'''
                +                      ' WHEN BKO.Status = ''3'' THEN ''Loaded'''
                +                      ' WHEN BKO.Status = ''9'' THEN ''Departed'''
                +                      ' END'
                + ' ,Order_Status = (SELECT MIN(CASE WHEN LPN.Status = ''0'' THEN ''0-Allocated'''
                +                      ' WHEN LPN.Status < ''5'' AND LPN.ProcessFlag = ''Y'' THEN ''3-Picking'''
                +                      ' WHEN LPN.Status < ''3'' THEN ''0-Allocated'''
                +                      ' WHEN LPN.Status = ''3'' THEN ''3-Picking'''
                +                      ' WHEN LPN.Status = ''5'' THEN ''5-Picked'''
                +                      ' WHEN LPN.Status = ''9'' THEN ''9-Shipped'''
                +                      ' END) FROM LOADPLAN LPN WITH (NOLOCK) WHERE LPN.BookingNo = BKO.BookingNo)'
                + ' ,Remarks = CASE WHEN BKO.Status = ''2'' AND GETDATE() > BKO.EndTime'
                +                 ' THEN ''Extended Loading'''
                +                 ' WHEN ISNUMERIC(FAC.USERDEFINE07) = 1 AND BKO.Status = ''0'' AND GETDATE() > DATEADD(hour, CONVERT(INT, FAC.USERDEFINE07), BKO.BookingDate)'
                +                 ' THEN ''Late Arrival'''
                +                 ' WHEN ISNUMERIC(FAC.USERDEFINE07) = 0 AND BKO.Status = ''0'' AND GETDATE() > DATEADD(hour, 0, BKO.BookingDate)'
                +                 ' THEN ''Late Arrival'''
                +                 ' WHEN ISNUMERIC(FAC.USERDEFINE07) = 1 AND BKO.Status = ''1'' AND GETDATE() > DATEADD(hour, CONVERT(INT, FAC.USERDEFINE07), BKO.BookingDate)'
                +                 ' THEN ''Late For Loading'''
                +                 ' WHEN ISNUMERIC(FAC.USERDEFINE07) = 0 AND BKO.Status = ''1'' AND GETDATE() > DATEADD(hour, 0, BKO.BookingDate)'
                +                 ' THEN ''Late For Loading'''
                +                 ' ELSE '''''
                +                 ' END'
                + ' ,BKO.Status'
                + ' FROM BOOKING_OUT BKO WITH (NOLOCK)'
                + ' JOIN LOADPLAN    LP  WITH (NOLOCK) ON (BKO.BookingNo = LP.BookingNo)'
                + ' JOIN ORDERS      OH  WITH (NOLOCK) ON (LP.Loadkey = OH.Loadkey)'
                + ' JOIN FACILITY    FAC WITH (NOLOCK) ON (BKO.Facility = FAC.Facility)'
                + ' ' + @c_SQLWhere  
                + ' AND OH.Storerkey = N''' + RTRIM(@c_Storerkey) + ''''
                + ' ORDER BY BKO.Facility'
                +       ' ,  RTRIM(OH.Storerkey)'
                +       ' ,  BKO.BookingDate'

      INSERT INTO #TMP_DSP2 ( Facility, Storerkey, BookingNo, BookingDate, EndTime, Loc, ToLoc, Loc2
                            , VehicleType, Truck_Name, Truck_Status, Order_Status, Remarks, BKO_Status
                            )
      EXEC ( @c_SQL )

      SET @n_TotalCnt = 0
      SELECT @n_TotalCnt = COUNT(1)
      FROM #TMP_DSP2
      WHERE Storerkey = @c_Storerkey

      IF @n_TotalCnt > 0 AND ( @n_TotalCnt % @n_RowPerPage ) > 0
      BEGIN
         SET @n_RecToIns = @n_RowPerPage - ( @n_TotalCnt % @n_RowPerPage ) 
      END 

      WHILE @n_RecToIns > 0 
      BEGIN
         INSERT INTO #TMP_DSP2 ( Facility, Storerkey, BookingNo, BookingDate, EndTime, Loc, ToLoc, Loc2
                               , VehicleType, Truck_Name, Truck_Status, Order_Status, Order_Status_Color, Remarks
                               , BKO_Status
                               )
         VALUES ('', '', NULL, NULL, NULL, '', '', ''
               , '', '','', '', NULL, ''
               , '')

         SET @n_RecToIns = @n_RecToIns - 1
      END
      FETCH NEXT FROM CUR_STR INTO @c_Storerkey
   END
   CLOSE CUR_STR
   DEALLOCATE CUR_STR

   QUIT_SP:
   SELECT RowNo
         ,Facility
         ,Storerkey
         ,BookingNo
         ,BookingDate
         ,EndTime
         ,Loc
         ,ToLoc
         ,Loc2
         ,VehicleType
         ,Truck_Name
         ,Truck_Status
         ,Order_Status = STUFF(Order_Status,1,2,'')
         ,Order_Status_Color = CASE LEFT(Order_Status,1) 
                                    WHEN '0' THEN 255        --Red
                                    WHEN '3' THEN 65535      --Yellow
                                    WHEN '5' THEN 32768      --Green
                                    WHEN '9' THEN 16711680   --Blue
                                    END
         ,Remarks
         ,PageGroup = CEILING ( (RowNo * 1.00) / @n_RowPerPage )
   FROM #TMP_DSP2
   ORDER BY RowNo

   IF CURSOR_STATUS( 'GLOBAL', 'CUR_STR') in (0 , 1)  
   BEGIN
      CLOSE CUR_STR
      DEALLOCATE CUR_STR
   END

   WHILE @@TRANCOUNT > 0 
      COMMIT TRAN

   WHILE @@TRANCOUNT < @n_starttcnt 
      BEGIN TRAN

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetBookingOut_Display2] TO nSQL 
GO

