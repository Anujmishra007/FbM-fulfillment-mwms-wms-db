SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store Procedure:  isp_Update_CareerKey_Granite                       */
/* Creation Date:  13-Sep-2024                                          */
/* Copyright: Maersk WMS                                                */
/* Written by:  USH022                                                  */
/* JIRA TICKET: UWP-23560                                               */
/* Purpose:  To update Orders.ShipperKey From Mbol.CareerKey            */
/*                                                                      */
/* Input Parameters:                                                    */
/*  @c_WaveKey                                                          */
/*  @c_StorerKey                                                        */
/*  @c_Facility                                                         */
/*  @c_Uom                                                              */
/*  @c_PickMethod                                                       */
/*  @c_LocationType                                                     */
/*                                                                      */
/* Output Parameters:  None                                             */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date             Author      Ver         Purposes                    */
/* YYYY-DD-MM       {author}    {ver}		{Comments}                    */
/* 2024-09-13        USH022      V.0		To Updated ShipperKey from    */
/*											         Mbol.CareerKey                */
/* 2025-09-02        HCK015      V.1      FCR-7640 - Update CarrierKey  */
/*                                         with Destination ID.         */
/* 2025-09-24        HCK015      V.2      FCR-8203 - Generate           */
/*                                         MBOL.ExternMbolKey(HCK015-02)*/
/************************************************************************/
CREATE OR ALTER     PROCEDURE [dbo].[isp_Update_CareerKey_Granite]
    @c_MbolKey    NVARCHAR(10),
    @b_Success		int            OUTPUT,
    @n_err			int            OUTPUT,
    @c_errmsg		NVARCHAR(250)  OUTPUT,
    @c_Code			NVARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON
    -- SQL 2005 Standard
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @c_StorerKey         NVARCHAR(10)
          , @c_Facility          NVARCHAR(20)
          , @c_successFlag       NVARCHAR(1)
          , @n_continue          INT
          , @n_StartTranCnt      INT
          , @c_CareerKey         NVARCHAR(10)
          , @c_OrderKey          NVARCHAR(10)

          --(HCK015) S
          , @c_ShipperKey        NVARCHAR(15)  
          , @c_ConsigneeKey      NVARCHAR(15)  
          , @b_IsParcelShipment  INT
          , @c_WCSCode           NVARCHAR(30)
          --(HCK015) E

          --(HCK015-02) S
          , @c_ExternMBOLKey     NVARCHAR(60)      = ''
          --(HCK015-02) E

    -- Begin Transaction
	SET @n_continue = 1;
	SELECT @n_StartTranCnt = @@TRANCOUNT;

	BEGIN TRAN;

   IF EXISTS(SELECT 1 FROM MBOL mbol WITH (NOLOCK) WHERE mbol.MBOLKey = @c_MbolKey AND mbol.Status = '9')
   BEGIN
      SELECT @n_continue = 3;
      SELECT @n_err = 63501;
      SELECT @c_errmsg='NSQL' + CONVERT(char(5), @n_err) + ': Carrier Key cannot be updated for Shipped Status.';
      GOTO RETURN_SP;
   END;

   IF NOT EXISTS(SELECT TOP (1) 1 FROM ORDERS O WITH (NOLOCK) WHERE O.MBOLKey = @c_MbolKey)
   BEGIN
      SELECT @n_continue = 3;
      SELECT @n_err = 63501;
      SELECT @c_errmsg='NSQL' + CONVERT(char(5), @n_err) + ': No Orders found with this ShipRef.';
      GOTO RETURN_SP;
   END;

   IF EXISTS (SELECT 1 FROM  MBOL mbol WITH (NOLOCK) WHERE
         mbol.MbolKey = @c_MbolKey AND
         (mbol.CarrierKey is null OR mbol.CarrierKey = '')
	)
   BEGIN
      SELECT @n_continue = 3;
      SELECT @n_err = 63501;
      SELECT @c_errmsg='NSQL' + CONVERT(char(5), @n_err) + ': No Carrierkey to update.';
      GOTO RETURN_SP;
   END;

   SELECT TOP 1 @c_StorerKey = O.StorerKey FROM ORDERS O WITH (NOLOCK) WHERE O.MBOLKey = @c_MbolKey
   
   DECLARE updateShipperKeyCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT mbol.CarrierKey, O.Orderkey
   FROM ORDERS O WITH (NOLOCK)
   JOIN MBOLDETAIL MD (NOLOCK) ON MD.MBOLKey = O.MBOLKey
   JOIN MBOL mbol WITH (NOLOCK) ON mbol.MbolKey = MD.MBOLKey
   WHERE O.StorerKey = @c_StorerKey AND O.Status < '9' 
   AND MD.MbolKey = @c_MbolKey 
   AND (mbol.CarrierKey is not null AND mbol.CarrierKey <> '')
   GROUP BY mbol.CarrierKey, O.Orderkey

   OPEN updateShipperKeyCursor;
   FETCH NEXT FROM updateShipperKeyCursor INTO @c_CareerKey, @c_OrderKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      UPDATE ORDERS WITH (ROWLOCK) SET ShipperKey = @c_CareerKey ,trafficcop = null
      WHERE OrderKey = @c_OrderKey;
   FETCH NEXT FROM updateShipperKeyCursor INTO @c_CareerKey, @c_OrderKey ;
   END;
   CLOSE updateShipperKeyCursor;
   DEALLOCATE updateShipperKeyCursor;

   --(HCK015) - Start
   DECLARE CUR_UPD_DISCHARGEPLACE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT O.OrderKey, O.ShipperKey, O.ConsigneeKey
   FROM ORDERS O WITH (NOLOCK) 
   JOIN MBOLDETAIL MD WITH (NOLOCK) ON MD.OrderKey = O.OrderKey
   WHERE MD.MBOLKey = @c_MbolKey
   --AND (O.DischargePlace IS NULL OR O.DischargePlace = '')

   OPEN CUR_UPD_DISCHARGEPLACE;
   FETCH NEXT FROM CUR_UPD_DISCHARGEPLACE INTO  @c_OrderKey, @c_ShipperKey, @c_ConsigneeKey
   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @b_IsParcelShipment = 0
      SET @c_WCSCode          = ''

      IF EXISTS ( SELECT 1 FROM CODELKUP CDLK WITH (NOLOCK)
                  WHERE CDLK.LISTNAME = 'WSCourier'
                  AND CDLK.Code = 'ECL-1'
                  AND EXISTS ( SELECT 1 FROM STORER S WITH (NOLOCK) 
                     WHERE S.StorerKey = @c_ShipperKey
                     AND S.[Type] = '7'
                     AND S.StorerKey = CDLK.Short ) )
      BEGIN
         SET @b_IsParcelShipment = 1
      END

      IF @b_IsParcelShipment = 1
      BEGIN
         SELECT @c_WCSCode = ISNULL(RTRIM(CDLK.Long), '')
         FROM CODELKUP CDLK WITH (NOLOCK)
         WHERE CDLK.LISTNAME = 'WCSDESTID'
         AND CDLK.StorerKey = @c_Storerkey
         AND CDLK.Code2 = @c_ShipperKey
         AND EXISTS ( SELECT 1 FROM STORER S WITH (NOLOCK) 
            WHERE S.StorerKey = @c_ConsigneeKey
            AND S.SUSR5 = CDLK.Short
            AND S.[Type] = '2' )
      END
      ELSE 
      BEGIN
         SELECT @c_WCSCode = ISNULL(RTRIM(CDLK.Long), '')
         FROM CODELKUP CDLK WITH (NOLOCK)
         WHERE CDLK.LISTNAME = 'WCSDESTID'
         AND CDLK.StorerKey = @c_Storerkey
         AND CDLK.Code2 = ''
         AND EXISTS ( SELECT 1 FROM STORER S WITH (NOLOCK) 
            WHERE S.StorerKey = @c_ConsigneeKey
            AND S.SUSR5 = CDLK.Short
            AND S.[Type] = '2' )
      END

      IF ISNULL(RTRIM(@c_WCSCode), '') = ''
      BEGIN
         SELECT @c_WCSCode = ISNULL(RTRIM(CDLK.Long), '')
         FROM CODELKUP CDLK (NOLOCK)  
         WHERE LISTNAME = 'WCSDESTID' 
         AND Code = 'Default'
      END

      UPDATE ORDERS WITH (ROWLOCK)
      SET DischargePlace = @c_WCSCode
         ,TrafficCop     = NULL
      WHERE OrderKey = @c_OrderKey

      FETCH NEXT FROM CUR_UPD_DISCHARGEPLACE INTO  @c_OrderKey, @c_ShipperKey, @c_ConsigneeKey
   END;
   CLOSE CUR_UPD_DISCHARGEPLACE;
   DEALLOCATE CUR_UPD_DISCHARGEPLACE;
   --(HCK015) - End

   --(HCK015-02) - S
   SELECT @c_ExternMBOLKey = ISNULL(RTRIM(ExternMBOLKey), '')
   FROM [dbo].[MBOL] WITH (NOLOCK) 
   WHERE MbolKey = @c_MbolKey

   IF @c_ExternMBOLKey = ''
   BEGIN
      --Generate ExternMBOLKey
      EXEC [dbo].[isp_GetVicsMbol]  
           @c_Mbolkey     = @c_MbolKey
         , @c_Vics_MBOL   = @c_ExternMBOLKey    OUTPUT  

      IF @c_ExternMBOLKey <> ''
      BEGIN
         UPDATE [dbo].[MBOL] WITH (ROWLOCK)
         SET ExternMBOLKey = @c_ExternMBOLKey
            ,TrafficCop = NULL
         WHERE MbolKey = @c_MbolKey
      END
   END
   --(HCK015-02) - E

   IF (@n_continue = 1)
   BEGIN
      SELECT @c_errmsg = 'Carrierkey has been updated.'
   END
	-- Error handling and commit/rollback
   RETURN_SP:
   IF CURSOR_STATUS('LOCAL', 'updateShipperKeyCursor') IN (0, 1)
   BEGIN
      CLOSE cur_repleinshment;
      DEALLOCATE cur_repleinshment;
   END;

   --(HCK015) - Start
   IF CURSOR_STATUS('LOCAL', 'CUR_UPD_DISCHARGEPLACE') IN (0, 1)
   BEGIN
      CLOSE CUR_UPD_DISCHARGEPLACE;
      DEALLOCATE CUR_UPD_DISCHARGEPLACE;
   END;
   --(HCK015) - End

   IF @n_continue = 3  -- Error Occurred - Process And Return
   BEGIN
      SELECT @b_Success = 0;
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         ROLLBACK TRAN;
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTranCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_Update_CareerKey_Granite'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_Success = 1;
      IF @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         COMMIT TRAN;
      END;
      RETURN;
   END;
END
GO
