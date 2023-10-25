create   trigger dbo.T_ON_UPDATE_Trades_ClientLoroAccount on dbo.ClientLoroAccount after update as
begin
    set nocount on
    if not exists( select 1
                     from inserted )
       and not exists( select 1
                         from deleted )
        return
         else
        begin
            insert into dbo.ClientLoroAccount_log
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
