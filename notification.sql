create table notifications (
  user_id varchar(64) primary key, 
  hour int,
  minute int,
  notification_disabled boolean default false
)