IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_loadplan_sheet_trade_ret]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_loadplan_sheet_trade_ret]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
create PROC isp_loadplan_sheet_trade_ret(    
 		 @c_loadkey NVARCHAR(10)    
 ) 
 AS     
 begin    
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
 declare @c_delivery_zone NVARCHAR(10),    
         @c_load_userdef1 NVARCHAR(200),    
         @n_ordercnt			int,    
         @d_adddate			datetime,    
         @c_trucksize		 NVARCHAR(10),    
         @c_storerkey		 NVARCHAR(15),    
         @c_orderkey		 NVARCHAR(15),    
         @c_type			 NVARCHAR(10),    
         @c_company		 NVARCHAR(45),    
         @c_teamleader	 NVARCHAR(255),    
         @c_driver			 NVARCHAR(255),    
         @c_deliveryman	 NVARCHAR(255),    
         @c_vehicle		 NVARCHAR(255),    
         @c_descr			 NVARCHAR(40),    
         @c_pmtterm		 NVARCHAR(10),  
 		  @c_load_userdef2 NVARCHAR(200) ,
 		  @c_externOrderkey NVARCHAR(30),
 		  @n_drop				int,
 		  @n_cube				float,
 		  @n_weight				float
 create table #result(    
 	   loadkey				 NVARCHAR(10),    
 	   adddate					datetime NULL,    
 	   teamleader			 NVARCHAR(255) null,    
 	   deliveryman			 NVARCHAR(255) null,    
 	   trucksize			 NVARCHAR(10) null,    
 	   vehicle				 NVARCHAR(255) null,    
 	   driver				 NVARCHAR(255) null,    
 	   deliveryarea		 NVARCHAR(10) null,    
 	   remark				 NVARCHAR(200) null,   
 	   ordercnt					int null,    
 	   storerkey			 NVARCHAR(15) NULL,    
 	   company				 NVARCHAR(45) NULL,  
 	   remark2				 NVARCHAR(200) NUll,
 	   dropcnt					int null,
 	   cube						float,
 	   weight					float    
 )    
 delete from ids_lp_nested_orderkey    
 declare cur1 cursor FAST_FORWARD READ_ONLY   
 FOR    
 	SELECT DISTINCT LOADPLANRETDETAIL.loadkey, 
 			LOADPLAN.delivery_zone, 
 			convert(NVARCHAR(200), LOADPLAN.load_userdef1), 
 			LOADPLAN.ordercnt, 
 			LOADPLAN.lpuserdefdate01, 
 			LOADPLAN.trucksize, 
 			RECEIPT.storerkey, 
 			STORER.company, 
 			convert(NVARCHAR(200), LOADPLAN.load_userdef2 ), 
 			cube = ( select sum(LOADPLANRETDETAIL.cube) from loadplanretdetail (nolock)
 					   where loadplanretdetail.loadkey = @c_loadkey ), 
 			weight = ( select sum(LOADPLANRETDETAIL.weight) from loadplanretdetail (nolock)
 					     where loadplanretdetail.loadkey = @c_loadkey ) 
 	FROM LOADPLAN (nolock)
 	JOIN LOADPLANRETDETAIL (nolock) ON LOADPLAN.LoadKey = LOADPLANRETDETAIL.LoadKey
 	JOIN RECEIPT (nolock) ON LOADPLANRETDETAIL.Loadkey = RECEIPT.Loadkey    
 	JOIN STORER (nolock) ON RECEIPT.storerkey = STORER.storerkey       
 	WHERE LOADPLAN.loadkey = @c_loadkey    
 	GROUP BY LOADPLANRETDETAIL.loadkey,  
 			LOADPLAN.delivery_zone, 
 			convert(NVARCHAR(200), LOADPLAN.load_userdef1), 
 			LOADPLAN.ordercnt, 
 			LOADPLAN.lpuserdefdate01, 
 			LOADPLAN.trucksize, 
 			RECEIPT.storerkey, 
 			STORER.company, 
 			convert(NVARCHAR(200), LOADPLAN.load_userdef2 ) 
 open cur1    
 fetch next from cur1 into @c_loadkey, @c_delivery_zone, @c_load_userdef1, @n_ordercnt, @d_adddate, @c_trucksize,
 								  @c_storerkey, @c_company, @c_load_userdef2 , @n_cube, @n_weight 
 SELECT @n_drop = COUNT(DISTINCT consigneekey)
   FROM ORDERS (NOLOCK)
  WHERE loadkey = @c_loadkey
 while (@@fetch_status=0)    
    begin    
       insert into #result    
       values(@c_loadkey, @d_adddate, @c_teamleader, @c_deliveryman, @c_trucksize, @c_vehicle, 
 				 @c_driver, @c_delivery_zone, @c_load_userdef1, @n_ordercnt, @c_storerkey, @c_company, 
 				 @c_load_userdef2, @n_drop, @n_cube, @n_weight)          
       fetch next from cur1 into @c_loadkey, @c_delivery_zone, @c_load_userdef1, @n_ordercnt, @d_adddate, @c_trucksize, 
 										  @c_storerkey, @c_company, @c_load_userdef2 , @n_cube, @n_weight 
    end    
 close cur1    
 deallocate cur1    
 --    Cur2 - to get team leader    
 declare cur2 cursor  FAST_FORWARD READ_ONLY   
 FOR    
 	SELECT CODELKUP.description    
 	  FROM IDS_LP_DRIVER (nolock) 
 	  JOIN CODELKUP (nolock) ON IDS_LP_DRIVER.drivercode = CODELKUP.code       
 	 WHERE IDS_LP_DRIVER.loadkey = @c_loadkey    
 		AND CODELKUP.listname = 'Driver'    
 		AND CODELKUP.short = 'TL'    
 		AND CODELKUP.long = 'Team Leader'    
 open cur2    
 fetch next from cur2 into @c_descr    
 while(@@fetch_status=0)    
    begin    
 	IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_teamleader)) <> ''
 	SELECT @c_teamleader = @c_teamleader + ' / '
       	set @c_teamleader = @c_teamleader + dbo.fnc_RTrim(@c_descr) -- + ' / '    
       	fetch next from cur2 into @c_descr    
    end    
 close cur2    
 deallocate cur2    
 UPDATE #result    
 	SET teamleader = @c_teamleader
 --substring(@c_teamleader,1,len(@c_teamleader)-3)    
 --    End of getting team leader    
 --    Cur3 - to get delivery man    
 declare cur3 cursor     FAST_FORWARD READ_ONLY
 FOR    
 	SELECT dbo.fnc_LTrim(dbo.fnc_RTrim(CODELKUP.description))    
 	  FROM IDS_LP_DRIVER (nolock) 
 	  JOIN CODELKUP (nolock) ON IDS_LP_DRIVER.drivercode = CODELKUP.code      
 	 WHERE IDS_LP_DRIVER.loadkey = @c_loadkey    
 		AND CODELKUP.listname = 'Driver'    
 		AND CODELKUP.short = 'DM'    
 		AND CODELKUP.long = 'Delivery Man'    
 open cur3    
 fetch next from cur3 into @c_descr    
 while(@@fetch_status=0)    
    begin    
 	IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_deliveryman)) <> ''
 	SELECT @c_deliveryman = @c_deliveryman + ' / '
         set @c_deliveryman =    @c_deliveryman + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_descr)) -- + ' / '
         fetch next from cur3 into @c_descr    
    end    
 close cur3    
 deallocate cur3    
 UPDATE #result    
 	SET deliveryman = @c_deliveryman 
 --substring(@c_deliveryman,1,len(@c_deliveryman)-3)    
 --    End of getting delivery man    
 --    Cur4 - to get driver    
 declare cur4 cursor     FAST_FORWARD READ_ONLY
 for    
 	select dbo.fnc_LTrim(dbo.fnc_RTrim(CODELKUP.description))    
 	  from IDS_LP_DRIVER (nolock) 
 	  JOIN CODELKUP (nolock) ON IDS_LP_DRIVER.drivercode = CODELKUP.code      
 	 where IDS_LP_DRIVER.loadkey = @c_loadkey    
 		and CODELKUP.listname = 'Driver'    
 		and CODELKUP.short = 'DR'    
 		and CODELKUP.long = 'Driver'    
 open cur4    
 fetch next from cur4 into @c_descr    
 while(@@fetch_status=0)    
    begin    
 		IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_driver)) <> ''
 			SELECT @c_driver = @c_driver + ' / '
       set @c_driver =    @c_driver + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_descr)) -- + ' / '
       fetch next from cur4 into @c_descr    
    end    
 close cur4    
 deallocate cur4    
 update #result    
 set driver = @c_driver -- substring(@c_driver,1,len(@c_driver)-3)    
 -- 	End of getting driver    
 declare cur5 cursor     FAST_FORWARD READ_ONLY
 for    
 select dbo.fnc_LTrim(dbo.fnc_RTrim(vehiclenumber)) from ids_lp_vehicle(nolock)    
  where loadkey = @c_loadkey    
  order by linenumber    
 open cur5    
 fetch next from cur5 into @c_descr    
 while (@@fetch_status=0)    
    begin    
 		IF dbo.fnc_LTrim(dbo.fnc_RTrim(@c_vehicle)) <> ''
 			SELECT @c_vehicle = @c_vehicle + ' / '
       set @c_vehicle = @c_vehicle + dbo.fnc_RTrim(@c_descr) -- + ' / '    
       fetch next from cur5 into @c_descr    
    end    
 close cur5    
 deallocate cur5    
 update #result    
 	set vehicle = '*' + @c_vehicle -- substring(@c_vehicle,1,len(@c_vehicle)-3)    
 select convert(NVARCHAR(30), Suser_Sname()) 'user_name', * from #result    
 -- select * From #result  
 drop table #result    
 SET NOCOUNT OFF  
 end
GO
GRANT EXECUTE ON [dbo].[isp_loadplan_sheet_trade_ret] TO nSQL 
GO
