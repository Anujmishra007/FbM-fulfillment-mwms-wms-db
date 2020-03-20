IF EXISTS (SELECT name FROM dbo.sysobjects WHERE name = 'nsp_archiveorders' AND type = 'P')
   DROP PROC nsp_archiveorders
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/****** Object:  Stored Procedure dbo.nsp_archiveorders    Script Date: 19/11/1998 10:12:10 AM ******/
CREATE PROC    nsp_archiveorders
 	@b_Success      int        OUTPUT,    
 	@n_err          int        OUTPUT,    
 	@c_errmsg       NVARCHAR(250)  OUTPUT    
 AS
 BEGIN  
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
    DECLARE	@n_continue 			int,  
 	   	@n_starttcnt 			int,
 	   	@n_cnt 				int,
 	   	@b_debug 			int,
 		@c_ShipActive 		 NVARCHAR(2),
 		@c_ShipStorerKeyStart 	 NVARCHAR(15),
 		@c_ShipStorerKeyEnd 	 NVARCHAR(15),
 		@c_ShipSysOrdStart 	 NVARCHAR(10),
 		@c_ShipSysOrdEnd 	 NVARCHAR(10),
 		@c_ShipYourOrdStart 	 NVARCHAR(30),
 		@c_ShipYourOrdEnd 	 NVARCHAR(30),
 		@c_ShipOrdTypStart 	 NVARCHAR(10),
 		@c_ShipOrdTypEnd 	 NVARCHAR(10),
 		@c_ShipOrdGrpStart 	 NVARCHAR(20),
 		@c_ShipOrdGrpEnd 	 NVARCHAR(20),
 		@c_ShipToStart 		 NVARCHAR(15),
 		@c_ShipToEnd 		 NVARCHAR(15),
 		@c_ShipBillToStart 	 NVARCHAR(15),
 		@c_ShipBillToEnd 	 NVARCHAR(15),
 		@n_retain_days			int,
 		@c_datetype 		 NVARCHAR(10),	
 		@CopyRowsToArchiveDatabase  NVARCHAR(1), 
 		@local_n_err 		        int,
 		@local_c_errmsg    	 NVARCHAR(254),
 		@c_whereclause 		 NVARCHAR(254),
 		@c_temp 		 NVARCHAR(254),
 		@c_temp1 		 NVARCHAR(254),
 		@d_result 			datetime
    SELECT @n_continue = 1, @n_err = 0, @c_errmsg = "",
 	  @local_n_err = 0, @local_c_errmsg = ' '
    SELECT @n_retain_days = ShipNumberofDaysToRetain,
           @c_datetype = ShipmentOrderdatetype,
 	  @c_ShipActive = ShipActive,
 	  @c_ShipStorerKeyStart = ShipStorerKeyStart,
 	  @c_ShipStorerKeyEnd = ShipStorerKeyEnd,
 	  @c_ShipSysOrdStart = ShipSysOrdStart,
 	  @c_ShipSysOrdEnd = ShipSysOrdEnd,
 	  @c_ShipYourOrdStart  = ShipExternOrderKeyStart,
 	  @c_ShipYourOrdEnd  = ShipExternOrderKeyEnd,
 	  @c_ShipOrdTypStart = ShipOrdTypStart,
 	  @c_ShipOrdTypEnd = ShipOrdTypEnd,
 	  @c_ShipOrdGrpStart = ShipOrdGrpStart,
 	  @c_ShipOrdGrpEnd = ShipOrdGrpEnd,
 	  @c_ShipToStart  = ShipToStart,
 	  @c_ShipToEnd  = ShipToEnd,
 	  @c_ShipBillToStart = ShipBillToStart,
 	  @c_ShipBillToEnd = ShipBillToEnd,
 	  @CopyRowsToArchiveDatabase = CopyRowsToArchiveDatabase
    FROM ArchiveParameters (NOLOCK)
    SELECT @d_result = DATEADD(DAY, -@n_retain_days, GETDATE())
    SELECT @d_result = DATEADD(DAY, 1, @d_result)
    SELECT @c_whereclause = ' '
    SELECT @c_temp = ' '
    SELECT @c_temp1 = ' '
    SELECT @c_temp = 'AND ORDERS.StorerKey BETWEEN '+ 'N'''+dbo.fnc_RTrim(@c_ShipStorerKeyStart) + ''''+ ' AND '+
           'N'''+dbo.fnc_RTrim(@c_ShipStorerKeyEnd)+''''
    SELECT @c_temp = @c_temp + ' AND ORDERS.ORDERKey BETWEEN '+ 'N''' + dbo.fnc_RTrim(@c_ShipSysOrdStart) + '''' +' AND '+
           'N'''+dbo.fnc_RTrim(@c_ShipSysOrdEnd)+''''
    SELECT @c_temp = @c_temp + ' AND ORDERS.ExternOrderKey BETWEEN '+ 'N''' + dbo.fnc_RTrim(@c_ShipYourOrdStart) + '''' +' AND '+
 	  'N'''+dbo.fnc_RTrim(@c_ShipYourOrdEnd)+''''
    SELECT @c_temp = @c_temp + ' AND ORDERS.Type BETWEEN '+ 'N''' + dbo.fnc_RTrim(@c_ShipOrdTypStart) + '''' +' AND '+
           'N'''+dbo.fnc_RTrim(@c_ShipOrdTypEnd)+''''
    SELECT @c_temp1 = @c_temp1 + ' AND ORDERS.ConsigneeKey BETWEEN '+ 'N''' + dbo.fnc_RTrim(@c_ShipToStart) + '''' +' AND '+
 	  'N'''+dbo.fnc_RTrim(@c_ShipToEnd)+''''
    SELECT @c_temp1 = @c_temp1 + ' AND ORDERS.BillToKey BETWEEN '+ 'N''' + dbo.fnc_RTrim(@c_ShipBillToStart) + '''' +' AND '+ 
           'N'''+dbo.fnc_RTrim(@c_ShipBillToEnd)+''''
    BEGIN TRAN
    IF @c_datetype = "1" -- ORDERSDATE
    BEGIN
       SELECT @c_whereclause = "UPDATE ORDERS SET Archivecop = '9' WHERE ORDERS.ORDERDate  <= " + 'N'''+ convert(char(20),@d_result,106)+'''' + " and ORDERS.Status = '9' " + " and (ORDERS.Archivecop = NULL or ORDERS.Archivecop is null) "
       EXECUTE (@c_whereclause)
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
    END
    IF @c_datetype = "2" -- EditDate
    BEGIN
       SELECT @c_whereclause = "UPDATE ORDERS SET Archivecop = '9' WHERE ORDERS.EditDate <= " + 'N'''+ convert(char(20),@d_result,106)+'''' + " and ORDERS.Status = '9' " + " and (ORDERS.Archivecop = NULL or ORDERS.Archivecop is null) "
       EXECUTE (@c_whereclause) 
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
    END
    IF @c_datetype = "3" -- AddDate
    BEGIN
   SELECT @c_whereclause = "UPDATE ORDERS SET Archivecop = '9' WHERE ORDERS.AddDate <= " +'N'''+ convert(char(20),@d_result,106)+'''' + " and ORDERS.Status = '9' " + " and (ORDERS.Archivecop = NULL or ORDERS.Archivecop is null) "
       EXECUTE (@c_whereclause)
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
    END
    IF @local_n_err <> 0
    BEGIN 
       SELECT @n_continue = 3
       SELECT @local_n_err = 77302
       SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
       SELECT @local_c_errmsg =
 	": Update of Archivecop failed - Shipping Orders (nspArchiveShippingOrder) " + " ( " +
 	" SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
    END  
    SELECT @c_whereclause
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN 
       UPDATE ORDERDETAIL
       SET ORDERDETAIL.Archivecop = '9'
       FROM ORDERS (NOLOCK), ORDERDETAIL (NOLOCK)
       WHERE (ORDERDETAIL.OrderKey = ORDERS.Orderkey)
       AND ORDERS.Archivecop = '9'
       AND (ORDERDETAIL.Archivecop = NULL or orderdetail.archivecop is null)
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
 	 SELECT @n_continue = 3
          SELECT @local_n_err = 77303
          SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
          SELECT @local_c_errmsg =
 	   ": Update of Archivecop failed - ORDERDETAIL. (nsp_ArchiveOrders) " + " ( " +
 	   " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END 
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN 
       UPDATE PICKDETAIL
       SET PICKDETAIL.Archivecop = '9'
       FROM ORDERS (NOLOCK), PICKDETAIL (NOLOCK)
       WHERE (PICKDETAIL.OrderKey = ORDERS.Orderkey)
       AND ORDERS.Archivecop = '9' 
       AND PICKDETAIL.STATUS = '9'
       AND (PICKDETAIL.Archivecop = NULL or pickdetail.archivecop is null)
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
 	 SELECT @local_n_err = 77304
 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
 	 SELECT @local_c_errmsg =
 	    ": Update of Archivecop failed - PICKDETAIL. (nsp_ArchiveOrders) " + " ( " +
 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END 
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN 
       UPDATE LoadPlanDetail
       SET LoadPlanDetail.Archivecop = '9'
       FROM ORDERS (NOLOCK), LoadPlanDetail (NOLOCK)
       WHERE (LoadPlanDetail.OrderKey = ORDERS.Orderkey 
       AND ORDERS.archivecop = '9'
       AND (LoadPlanDetail.Archivecop = NULL or loadplandetail.archivecop is null))
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
       	 SELECT @local_n_err = 77304
       	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
       	 SELECT @local_c_errmsg =
 	    ": Update of Archivecop failed - LoadPlanDetail. (nsp_ArchiveOrders) " + " ( " +
 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END 
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN 
       UPDATE LoadPlan
       SET LoadPlan.Archivecop = '9'
       FROM LoadPlan (NOLOCK), LoadPlanDetail (NOLOCK)
       WHERE (LoadPlan.LoadKey = LoadPlanDetail.LoadKey
       AND LoadPlanDetail.archivecop = '9' 
       AND (LoadPlan.Archivecop = NULL or loadplan.archivecop is null))
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
 	 SELECT @local_n_err = 77304
 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
 	 SELECT @local_c_errmsg =
 	    ": Update of Archivecop failed - LoadPlan. (nsp_ArchiveOrders) " + " ( " +
 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END 
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN 
       UPDATE MBOLDETAIL
       SET MBOLDETAIL.Archivecop = '9'
       FROM ORDERS (NOLOCK), MBOLDETAIL (NOLOCK), MBOL (NOLOCK)
       WHERE (MBOLDETAIL.OrderKey = ORDERS.Orderkey 
       AND ORDERS.archivecop = '9'
       AND MBOLDETAIL.MBOLKey = MBOL.MBOLKey
       AND MBOL.Status = '9'
       AND (MBOLDETAIL.Archivecop = NULL or mboldetail.archivecop is null))
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
 	 SELECT @local_n_err = 77304
 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
 	 SELECT @local_c_errmsg =
 	    ": Update of Archivecop failed - MBOLDETAIL. (nsp_ArchiveOrders) " + " ( " +
 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END 
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN 
       UPDATE MBOL
       SET MBOL.Archivecop = '9'
       FROM MBOL (NOLOCK), MBOLDETAIL (NOLOCK)
       WHERE (MBOL.MbolKey = MBOLDETAIL.MbolKey
       AND MBOLDETAIL.archivecop = '9' 
       AND MBOL.STATUS = '9'
       AND (MBOL.Archivecop = NULL or mbol.archivecop is null))
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
 	 SELECT @local_n_err = 77304
 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
 	 SELECT @local_c_errmsg =
 	    ": Update of Archivecop failed - MBOL. (nsp_ArchiveOrders) " + " ( " +
 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END 
    IF (@n_continue = 1 or @n_continue = 2)
       COMMIT TRAN
    ELSE
       ROLLBACK TRAN
 
	 BEGIN TRAN
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       IF NOT EXISTS(SELECT * FROM ARCHIVE..sysobjects (NOLOCK)
          WHERE ARCHIVE..sysobjects.name = 'ORDERS')
       BEGIN
          SELECT * INTO ARCHIVE..ORDERS
          FROM ORDERS (NOLOCK)
          WHERE Archivecop = '9'
       END
       ELSE
       BEGIN
          INSERT INTO ARCHIVE..ORDERS
          SELECT * FROM ORDERS (NOLOCK)
          WHERE Archivecop = '9'
       END
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
 	 		 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": INSERT failed - ORDERS. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       DELETE FROM ORDERS
       WHERE Archivecop = '9'
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": DELETE failed - ORDERS. (nsp_ArchiveOrders) " + " ( " +
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END	

    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       IF NOT EXISTS(SELECT * FROM ARCHIVE..sysobjects (NOLOCK)
          WHERE ARCHIVE..sysobjects.name = 'ORDERDETAIL')
       BEGIN
          SELECT * INTO ARCHIVE..ORDERDETAIL
 	 		 FROM ORDERDETAIL (NOLOCK)
 	 		 WHERE Archivecop = '9'
       END
       ELSE
       BEGIN
          INSERT INTO ARCHIVE..ORDERDETAIL
          SELECT * FROM ORDERDETAIL (NOLOCK)
          WHERE Archivecop = '9'
       END
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": INSERT failed - ORDERDETAIL. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

	 IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       DELETE FROM ORDERDETAIL
       WHERE Archivecop = '9'
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": DELETE failed - ORDERDETAIL. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END
    
	 IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       IF NOT EXISTS(SELECT * FROM ARCHIVE..sysobjects (NOLOCK)
          WHERE ARCHIVE..sysobjects.name = 'PICKDETAIL')
       BEGIN      
          SELECT * INTO ARCHIVE..PICKDETAIL
          FROM PICKDETAIL (NOLOCK)
 	 		 WHERE Archivecop = '9'
       END
       ELSE
       BEGIN
          INSERT INTO ARCHIVE..PICKDETAIL
          SELECT * FROM PICKDETAIL (NOLOCK)
          WHERE Archivecop = '9'
       END
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": INSERT failed - PICKDETAIL. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

	 IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       DELETE PICKDETAIL
       FROM   ARCHIVE..PICKDETAIL AP 
       WHERE PICKDETAIL.Archivecop = '9'
       AND   AP.PickDetailKey = PICKDETAIL.PickDetailKey
   
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": DELETE failed - PICKDETAIL. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       IF NOT EXISTS(SELECT * FROM ARCHIVE..sysobjects (NOLOCK)
          WHERE ARCHIVE..sysobjects.name = 'LoadPlanDetail')
       BEGIN      
 	 		 SELECT * INTO ARCHIVE..LoadPlanDetail
          FROM LoadPlanDetail (NOLOCK)
          WHERE Archivecop = '9'      
       END
       ELSE
       BEGIN
          INSERT INTO ARCHIVE..LoadPlanDetail
          SELECT * FROM LoadPlanDetail (NOLOCK)
          WHERE Archivecop = '9'
       END
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": INSERT failed - LoadPlanDetail. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

	 IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       DELETE FROM LoadPlanDetail
       WHERE Archivecop = '9'
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": DELETE failed - LoadPlanDetail. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       IF NOT EXISTS(SELECT * FROM ARCHIVE..sysobjects (NOLOCK)
          WHERE ARCHIVE..sysobjects.name = 'LoadPlan')
       BEGIN 
          SELECT * INTO ARCHIVE..LoadPlan
          FROM LoadPlan (NOLOCK)
 	 WHERE Archivecop = '9'
       END
       ELSE
       BEGIN 
          INSERT INTO ARCHIVE..LoadPlan
          SELECT * FROM LoadPlan (NOLOCK)
          WHERE Archivecop = '9'
       END
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": INSERT failed - LoadPLan. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

	 IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       DELETE FROM LoadPlan
       WHERE Archivecop = '9'
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": DELETE failed - LoadPlan. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       IF NOT EXISTS(SELECT * FROM ARCHIVE..sysobjects (NOLOCK)
          WHERE ARCHIVE..sysobjects.name = 'MBOLDETAIL')
       BEGIN 
          SELECT * INTO ARCHIVE..MBOLDETAIL
          FROM MBOLDETAIL (NOLOCK)
 	 		 WHERE Archivecop = '9'
       END
       ELSE
       BEGIN 
          INSERT INTO ARCHIVE..MBOLDETAIL
          SELECT * FROM MBOLDETAIL (NOLOCK)
          WHERE Archivecop = '9'
       END
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": INSERT failed - MBOLDETAIL. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

	 IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       DELETE FROM MBOLDETAIL
       WHERE Archivecop = '9'
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": DELETE failed - MBOLDETAIL. (nsp_ArchiveOrders) " + " ( " + " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       IF NOT EXISTS(SELECT * FROM ARCHIVE..sysobjects (NOLOCK)
          WHERE ARCHIVE..sysobjects.name = 'MBOL')
       BEGIN      
 	 		 SELECT * INTO ARCHIVE..MBOL
          FROM MBOL (NOLOCK)
          WHERE Archivecop = '9'      
       END
       ELSE
       BEGIN
          INSERT INTO ARCHIVE..MBOL
          SELECT * FROM MBOL (NOLOCK)
          WHERE Archivecop = '9'
       END
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": INSERT failed - MBOL. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END
     
    IF (@n_continue = 1 or @n_continue = 2)
    BEGIN
       DELETE FROM MBOL
       WHERE Archivecop = '9'
       SELECT @local_n_err = @@ERROR
       SELECT @n_cnt = @@ROWCOUNT
       IF @local_n_err <> 0
       BEGIN 
          SELECT @n_continue = 3
		 	 SELECT @local_n_err = 77304
		 	 SELECT @local_c_errmsg = CONVERT(char(5),@local_n_err)
		 	 SELECT @local_c_errmsg =
		 	    ": DELETE failed - MBOL. (nsp_ArchiveOrders) " + " ( " +
		
		 	    " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
       END  
    END

    IF (@n_continue = 1 or @n_continue = 2)
       COMMIT TRAN
    ELSE
       ROLLBACK TRAN
END

GO 
GRANT EXECUTE ON nsp_archiveorders TO NSQL 
GO
