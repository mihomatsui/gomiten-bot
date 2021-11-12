insert into categories (id, type) values (0, 可燃ゴミ)on conflict do nothing;
insert into categories (id, type) values (1, 不燃ゴミ)on conflict do nothing;
insert into categories (id, type) values (2, プラスチックゴミ)on conflict do nothing;
insert into categories (id, type) values (3, 缶・ビン・ペットボトル)on conflict do nothing;