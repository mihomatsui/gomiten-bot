insert into garbage (id, address_id, nweek, wday, category_id) values 
  (0, 1, 0, '火', 0),
  (1, 1, 0, '金', 0),
  (2, 1, 4, '水', 1),
  (3, 1, 0, '木', 3),
  (4, 1, 0, '水', 2)on conflict (id) do update set address_id = excluded.address_id, nweek = excluded.nweek, wday = excluded.wday, category_id = excluded.category_id;
