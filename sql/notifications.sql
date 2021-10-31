create table if not exists notifications (
  user_id varchar(64) primary key, 
  hour int,
  minute int,
  area_id int,
  is_enabled boolean default false
)
