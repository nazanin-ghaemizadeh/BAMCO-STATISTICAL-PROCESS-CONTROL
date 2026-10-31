drop policy if exists spc_active_members_select on public.spc_quality_characteristics;
drop policy if exists spc_active_members_insert on public.spc_quality_characteristics;
drop policy if exists spc_active_members_update on public.spc_quality_characteristics;
drop policy if exists spc_active_members_delete on public.spc_quality_characteristics;
alter table public.spc_quality_characteristics enable row level security;
create policy spc_feature_read on public.spc_quality_characteristics for select to authenticated using (public.can_access_feature('statisticalProcessControl','view'));
create policy spc_feature_create on public.spc_quality_characteristics for insert to authenticated with check (created_by=(select auth.uid()) and public.can_access_feature('statisticalProcessControl','create'));
create policy spc_feature_edit on public.spc_quality_characteristics for update to authenticated using (public.can_access_feature('statisticalProcessControl','edit')) with check (public.can_access_feature('statisticalProcessControl','edit'));
create policy spc_feature_delete on public.spc_quality_characteristics for delete to authenticated using (public.can_access_feature('statisticalProcessControl','delete'));
create or replace function private.spc_stamp() returns trigger language plpgsql set search_path='' as $$
begin
 if TG_OP='INSERT' then NEW.created_by:=auth.uid(); NEW.created_at:=clock_timestamp();
 else NEW.id:=OLD.id;NEW.created_by:=OLD.created_by;NEW.created_at:=OLD.created_at;end if;
 NEW.updated_at:=clock_timestamp();return NEW;
end $$;
revoke all on function private.spc_stamp() from public,anon,authenticated;
create trigger spc_stamp before insert or update on public.spc_quality_characteristics for each row execute function private.spc_stamp();
grant select,insert,update,delete on public.spc_quality_characteristics to authenticated;
revoke all on public.spc_quality_characteristics from anon;
