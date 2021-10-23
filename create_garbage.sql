create type week as enum('1', '2', '3', '4', '毎週');
create type wday as enum('日', '月', '火', '水', '木', '金', '土');

create table if not exists garbage (
  id int primary key, 
  address_id int references addresses(id),
  weektype week,
  wdaytype wday
  category_id int references category(id)
)

