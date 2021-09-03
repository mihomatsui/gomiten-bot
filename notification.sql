create table notifications (
  user_id varchar(64) primary key, 
  hour int,
  minute int,
  area_id int,
  notificationDisabled boolean default false
)