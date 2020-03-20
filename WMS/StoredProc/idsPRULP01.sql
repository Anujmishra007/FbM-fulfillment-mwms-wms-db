if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[idsPRULP01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[idsPRULP01]
GO

 
GO
SET ANSI_NULLS OFF 
GO

CREATE proc idsPRULP01
  	@c_storerkey NVARCHAR(15) ,
  	@c_sku NVARCHAR(20) ,
  	@c_lot NVARCHAR(10) ,
  	@c_lottable01 NVARCHAR(18) ,
  	@c_lottable02 NVARCHAR(18) ,
  	@c_lottable03 NVARCHAR(18) ,
  	@c_lottable04 datetime,
  	@c_lottable05 datetime,
  	@c_uom NVARCHAR(10) ,
	@c_facility NVARCHAR(10)  ,  -- added By Ricky for IDSV5
  	@n_uombase int ,
  	@n_qtylefttofulfill int
  AS
  BEGIN -- main
     
  SET NOCOUNT ON
  	/* Get SKU Shelf Life */
  	DECLARE @n_shelflife int
  	SELECT @n_shelflife = Sku.Shelflife 
  	FROM  Sku (nolock)
  	WHERE SKU.sku = @c_sku
  	IF LTRIM(RTRIM(@n_shelflife)) IS NULL SELECT @n_shelflife = 0
  	
  	if ltrim(rtrim(@c_lot)) is not null
  	begin
  		declare preallocate_cursor_candidates scroll cursor
  		for
  			select lot.storerkey, lot.sku, lot.lot, 
  				qtyavailable = (lot.qty-lot.qtyallocated-lot.qtypicked) - (lot.qtypreallocated+lot.qtyonhold)
  			from lotxlocxid (nolock) join lot (nolock)
  				on lotxlocxid.lot = lot.lot
  			join lotattribute (nolock)
  				on lotxlocxid.lot = lotattribute.lot
  			join loc (nolock)
  				on lotxlocxid.loc = loc.loc
         join id(nolock)    -- SOS131215 Start ang01
            on lotxlocxid.id = id.id   --SOS131215 End ang01
  			where lotxlocxid.lot = @c_lot
 				and lotxlocxid.qty > 0
  				and lot.status = 'OK'
            and Id.status = 'OK' -- SOS131215 Start ang01
            and Loc.status = 'OK' -- SOS131215 End  ang01
				AND LOC.Facility = @c_facility  -- Added By Ricky for IDSV5
  				and loc.locationflag = 'NONE'
  				and (loc.locationtype = 'SELECTIVE' or loc.locationtype = 'DRIVEIN')
  				and dateadd(day, @n_shelflife, lottable04) < getdate()
  			group by lot.storerkey, lot.sku, lot.lot, lottable04, lot.qty, lot.qtyallocated, lot.qtypicked,
 								lot.qtypreallocated, lot.qtyonhold
  			having (lot.qty-lot.qtyallocated-lot.qtypicked) - (lot.qtypreallocated+lot.qtyonhold) > 0
  			order by min(loc.hostwhcode), lottable04
  	end
  	else -- if ltrim(rtrim(@c_lot)) is not null
  	begin
  		declare preallocate_cursor_candidates scroll cursor
  		for
  		select lot.storerkey, lot.sku, lot.lot, 
  				qtyavailable = (lot.qty-lot.qtyallocated-lot.qtypicked) - (lot.qtypreallocated+lot.qtyonhold)
  			from lotxlocxid (nolock) join lot (nolock)
  				on lotxlocxid.lot = lot.lot
  			join lotattribute (nolock)
  				on lotxlocxid.lot = lotattribute.lot
  			join loc (nolock)
  				on lotxlocxid.loc = loc.loc
         join id(nolock)    -- SOS131215 Start ang01
            on lotxlocxid.id = id.id   --SOS131215 End ang01
  			where lotxlocxid.storerkey = @c_storerkey
  				and lotxlocxid.sku = @c_sku
 				and lotxlocxid.qty > 0
  				and lot.status = 'OK' 
            and Id.status = 'OK' -- SOS131215 Start ang01
            and Loc.status = 'OK' -- SOS131215 End ang01 
				AND LOC.Facility = @c_facility  -- Added By Ricky for IDSV5
  				and loc.locationflag = 'NONE'
  				and (loc.locationtype = 'SELECTIVE' or loc.locationtype = 'DRIVEIN')
  				and dateadd(day, @n_shelflife, lottable04) < getdate()
  			group by lot.storerkey, lot.sku, lot.lot, lottable04, lot.qty, lot.qtyallocated, lot.qtypicked,
 								lot.qtypreallocated, lot.qtyonhold
  			having (lot.qty-lot.qtyallocated-lot.qtypicked) - (lot.qtypreallocated+lot.qtyonhold) > 0
  			order by min(loc.hostwhcode), lottable04
  	end
  end -- main

GO
 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON idsPRULP01 to nSQL
GO
