insert into category (id, classification) values 
(0, '可燃ゴミ'),
(1, '不燃ゴミ'),
(2, '缶・びん・ペットボトル'),
(3, 'プラスチックゴミ')on conflict (id) do update set classification = excluded.classification;
