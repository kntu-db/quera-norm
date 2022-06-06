create function publish() returns trigger as
$$
begin
    update problemset set public = true where class = new.id;
end
$$ language plpgsql;

create trigger publishAfterArchive
    after update
    on class
    for each row
    when (new.archived and new.publishafterarchive)
execute function publish();