

update tbl_archiveconfig set arc_code = 'RFPutaway_DEL', Description = 'Archive RFPutaway_DEL' , SrcTableName = 'RFPutaway_DEL'
where arc_code = 'RFPutaway_DELLOG'

update tbl_purgeconfig set Item = 'RFPutaway_DEL', TBLName = 'RFPutaway_DEL', Description = 'Purge  RFPutaway_DEL'
where Item = 'RFPUTAWAY_DELLOG'


