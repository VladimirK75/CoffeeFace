create   trigger T_ON_UPDATE_Trades_SettlementRules on dbo.Trades_SettlementRules after insert, update, delete as
begin
    set nocount on
    if not exists (select 1
                     from inserted)
       and not exists (select 1
                         from deleted) 
        return
       else
        begin
            insert into dbo.Trades_SettlementRules_Log
            select *
                 , AuditDateTime_log = getdate()
                 , AuditActions = 'D'
                 , AuditUser = suser_name()
              from deleted
            union all
            select *
                 , AuditDateTime_log = getdate()
                 , AuditActions = 'I'
                 , AuditUser = suser_name()
              from inserted
        end
end
