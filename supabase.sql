-- =====================================================================
--  WePink · Coleção de Perfumes — script do banco de dados (Supabase)
--  Como usar: Supabase → SQL Editor → New query → cole tudo → RUN.
--  Pode rodar quantas vezes quiser (ele recria a tabela do zero).
-- =====================================================================

drop table if exists public.perfumes;

create table public.perfumes (
  id         bigint generated always as identity primary key,
  slug       text         not null unique,   -- usado p/ casar com o catálogo da WePink
  position   int          not null default 1000,
  name       text         not null,
  reaction   text         check (reaction in ('like','dislike')),  -- null = não avaliado
  owned      boolean      not null default false,
  products   jsonb        not null default '[]'::jsonb,
  tag        text,
  photo_url  text,
  vtex_link  text,
  created_at timestamptz  not null default now()
);

create index perfumes_position_idx on public.perfumes (position);

-- Libera leitura/escrita pública p/ o site (app sem login). Veja o README sobre segurança.
-- (A função de sincronização usa a service key e NÃO depende destas regras.)
alter table public.perfumes enable row level security;

drop policy if exists "leitura publica" on public.perfumes;
drop policy if exists "escrita publica" on public.perfumes;
create policy "leitura publica" on public.perfumes for select using (true);
create policy "escrita publica" on public.perfumes for update using (true) with check (true);

-- ---------------------------------------------------------------------
--  Dados iniciais (101 perfumes)
-- ---------------------------------------------------------------------
insert into public.perfumes (position, slug, name, reaction, owned, products, tag) values
  (1, 'vf', 'VF', 'like', true, '["Perfume","Óleo","Creme","Roll-on"]'::jsonb, NULL),
  (2, 'vf-aqua', 'VF Aqua', 'like', true, '["Perfume","Óleo","Creme"]'::jsonb, NULL),
  (3, 'vf-choices', 'VF Choices', 'like', true, '["Perfume","Creme"]'::jsonb, NULL),
  (4, 'vf-choices-delight', 'VF Choices Delight', 'like', false, '["Perfume"]'::jsonb, NULL),
  (5, 'vf-bloom', 'VF Bloom', 'like', true, '["Perfume"]'::jsonb, NULL),
  (6, 'vf-ballet', 'VF Ballet', 'like', false, '["Perfume"]'::jsonb, NULL),
  (7, 'vf-golden', 'VF Golden', 'like', false, '["Perfume","Óleo","Creme","Scrub"]'::jsonb, NULL),
  (8, 'vf-seduce', 'VF Seduce', 'like', false, '["Perfume"]'::jsonb, NULL),
  (9, 'vf-onyx', 'VF Onyx', 'like', false, '["Perfume"]'::jsonb, NULL),
  (10, 'vf-2-7', 'VF 2.7', NULL, false, '["Perfume"]'::jsonb, NULL),
  (11, 'vf-tropical', 'VF Tropical', NULL, false, '["Perfume"]'::jsonb, NULL),
  (12, 'vf-honey', 'VF Honey', 'dislike', false, '["Perfume","Creme"]'::jsonb, NULL),
  (13, 'obssesed', 'Obssesed', 'like', true, '["Perfume","Óleo","Creme","Roll-on","Hair mist"]'::jsonb, NULL),
  (14, 'obssesed-gold', 'Obssesed Gold', 'like', true, '["Perfume","Creme","Óleo"]'::jsonb, NULL),
  (15, 'obssesed-deluxe', 'Obssesed Deluxe', 'like', true, '["Perfume"]'::jsonb, NULL),
  (16, 'obssesed-exclusive-pink', 'Obssesed Exclusive Pink', 'like', true, '["Perfume"]'::jsonb, NULL),
  (17, 'obsessed-intense', 'Obsessed Intense', 'like', true, '["Perfume"]'::jsonb, NULL),
  (18, 'obsessed-lovely', 'Obsessed Lovely', 'like', true, '["Perfume","Creme"]'::jsonb, NULL),
  (19, 'liberte', 'Liberté', 'like', true, '["Perfume","Óleo","Creme","Roll-on","Hair mist","Scrub"]'::jsonb, NULL),
  (20, 'liberte-nuit', 'Liberté Nuit', 'like', true, '["Perfume"]'::jsonb, NULL),
  (21, 'liberte-exclusif', 'Liberté Exclusif', 'like', true, '["Perfume","Creme","Scrub"]'::jsonb, NULL),
  (22, 'liberte-platine', 'Liberté Platiné', 'like', true, '["Perfume"]'::jsonb, NULL),
  (23, 'liberte-dore', 'Liberté Doré', 'like', false, '["Perfume"]'::jsonb, NULL),
  (24, 'red', 'Red', 'like', true, '["Perfume","Óleo","Creme","Roll-on","Hair mist","Scrub"]'::jsonb, NULL),
  (25, 'red-obsidian', 'Red Obsidian', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (26, 'red-mirage', 'Red Mirage', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (27, 'pureblixx', 'Pureblixx', 'like', true, '["Perfume","Óleo","Creme"]'::jsonb, NULL),
  (28, 'pureblixx-mauve', 'Pureblixx Mauve', 'like', false, '["Perfume"]'::jsonb, NULL),
  (29, 'pureblixx-darkest', 'Pureblixx Darkest', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (30, 'one-touch', 'One Touch', 'like', false, '["Perfume","Óleo","Creme"]'::jsonb, NULL),
  (31, 'one-touch-silk', 'One Touch Silk', 'like', false, '["Perfume","Creme"]'::jsonb, NULL),
  (32, 'one-touch-warm', 'One Touch Warm', 'dislike', false, '["Perfume","Creme"]'::jsonb, NULL),
  (33, 'one-touch-latte', 'One Touch Latte', NULL, false, '["Perfume","Creme"]'::jsonb, NULL),
  (34, 'infinity', 'Infinity', 'like', false, '["Perfume","Óleo","Creme","Roll-on"]'::jsonb, NULL),
  (35, 'infinity-star', 'Infinity Star', 'like', false, '["Perfume","Óleo","Creme"]'::jsonb, NULL),
  (36, 'infinity-crystal', 'Infinity Crystal', 'like', false, '["Perfume"]'::jsonb, NULL),
  (37, 'infinity-cosmik', 'Infinity Cosmik', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (38, 'infinity-xis', 'Infinity Xis', 'like', false, '["Perfume","Creme"]'::jsonb, NULL),
  (39, 'infinity-plim', 'Infinity Plim', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (40, 'infinity-tawny', 'Infinity Tawny', NULL, false, '["Perfume"]'::jsonb, NULL),
  (41, 'celebrate-luck', 'Celebrate Luck', 'like', false, '["Perfume"]'::jsonb, NULL),
  (42, 'celebrate-relics', 'Celebrate Relics', 'like', false, '["Perfume"]'::jsonb, NULL),
  (43, 'celebrate-sunset', 'Celebrate Sunset', NULL, false, '["Perfume"]'::jsonb, NULL),
  (44, 'celebrate-life', 'Celebrate Life', 'dislike', false, '["Perfume","Óleo","Creme","Roll-on"]'::jsonb, NULL),
  (45, 'celebrate-happy', 'Celebrate Happy', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (46, 'perfect-pear', 'Perfect Pear', 'like', false, '["Perfume","Creme","Óleo","Roll-on","Scrub"]'::jsonb, NULL),
  (47, 'pure-pear', 'Pure Pear', 'like', false, '["Perfume"]'::jsonb, NULL),
  (48, 'the-lover', 'The Lover', 'like', false, '["Perfume"]'::jsonb, NULL),
  (49, 'the-rainy', 'The Rainy', 'like', false, '["Perfume"]'::jsonb, NULL),
  (50, 'the-sunny', 'The Sunny', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (51, 'universe-moon', 'Universe Moon', 'like', false, '["Perfume"]'::jsonb, NULL),
  (52, 'universe-earth', 'Universe Earth', 'like', false, '["Perfume"]'::jsonb, NULL),
  (53, 'heaven-groom', 'Heaven Groom', 'like', false, '["Perfume"]'::jsonb, 'Masc'),
  (54, 'heaven-bride', 'Heaven Bride', 'like', false, '["Perfume","Creme"]'::jsonb, NULL),
  (55, 'heaven', 'Heaven', 'dislike', false, '["Perfume","Hair mist"]'::jsonb, NULL),
  (56, 'heaven-blue', 'Heaven Blue', 'dislike', false, '["Perfume","Creme"]'::jsonb, NULL),
  (57, 'heaven-santal-fig', 'Heaven Santal & Fig', NULL, false, '["Perfume"]'::jsonb, NULL),
  (58, 'fatal-rouge', 'Fatal Rouge', 'like', false, '["Perfume","Creme","Scrub","Roll-on"]'::jsonb, NULL),
  (59, 'fatal-black', 'Fatal Black', 'dislike', false, '["Perfume","Creme"]'::jsonb, NULL),
  (60, 'fatal-white', 'Fatal White', 'like', false, '["Perfume"]'::jsonb, NULL),
  (61, 'le-grand-club-little-angel', 'Le Grand Club Little Angel', 'like', false, '["Perfume"]'::jsonb, NULL),
  (62, 'le-grand-club-sweet-lady', 'Le Grand Club Sweet Lady', NULL, false, '["Perfume"]'::jsonb, NULL),
  (63, 'le-grand-club-secret-lover', 'Le Grand Club Secret Lover', NULL, false, '["Perfume"]'::jsonb, NULL),
  (64, 'changes', 'Changes', 'like', false, '["Perfume","Creme","Roll-on"]'::jsonb, NULL),
  (65, 'queen-pink', 'Queen Pink', 'like', false, '["Perfume"]'::jsonb, NULL),
  (66, 'merry-christmas', 'Merry Christmas', 'like', false, '["Perfume"]'::jsonb, NULL),
  (67, 'happy-new-year', 'Happy New Year', 'like', false, '["Perfume"]'::jsonb, NULL),
  (68, 'auretex', 'Auretex', 'like', false, '["Perfume"]'::jsonb, NULL),
  (69, 'scarlette', 'Scarlette', 'like', false, '["Perfume","Creme"]'::jsonb, NULL),
  (70, 'fusion-for-her', 'Fusion For Her', NULL, false, '["Perfume","Óleo","Creme"]'::jsonb, NULL),
  (71, 'wonderful', 'Wonderful', 'like', false, '["Perfume","Óleo"]'::jsonb, NULL),
  (72, 'crimson-seraph', 'Crimson Seraph', 'like', false, '["Perfume"]'::jsonb, NULL),
  (73, 'ember-divinus', 'Ember Divinus', NULL, false, '["Perfume"]'::jsonb, NULL),
  (74, 'ghadan', 'Ghadan', NULL, false, '["Perfume","Creme"]'::jsonb, NULL),
  (75, 'martin', 'Martin', NULL, false, '["Perfume"]'::jsonb, NULL),
  (76, 'feive', 'Feive', 'dislike', false, '["Perfume","Creme"]'::jsonb, NULL),
  (77, 'feive-celestial', 'Feive Celestial', 'like', false, '["Perfume","Creme"]'::jsonb, NULL),
  (78, 'yahya-sadeeq', 'Yahya Sadeeq', NULL, false, '["Perfume","Creme"]'::jsonb, NULL),
  (79, 'haylas', 'Haylas', NULL, false, '["Perfume"]'::jsonb, NULL),
  (80, 'flora-whisper', 'Flora Whisper', 'like', false, '["Perfume"]'::jsonb, NULL),
  (81, 'wonbloom', 'Wonbloom', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (82, 'wonbloom-charm', 'Wonbloom Charm', 'like', false, '["Perfume"]'::jsonb, NULL),
  (83, 'crave', 'Crave', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (84, 'crave-lovely', 'Crave Lovely', 'like', false, '["Perfume"]'::jsonb, NULL),
  (85, '4-dreams', '4 Dreams', NULL, false, '["Perfume"]'::jsonb, NULL),
  (86, 'pink', 'Pink', 'dislike', false, '["Perfume","Óleo","Creme"]'::jsonb, NULL),
  (87, 'purple', 'Purple', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (88, 'divine', 'Divine', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (89, 'ruby', 'Ruby', 'dislike', false, '["Perfume"]'::jsonb, NULL),
  (90, 'ruby-ametist', 'Ruby Ametist', 'like', false, '["Perfume"]'::jsonb, NULL),
  (91, 'ruby-rhodolite', 'Ruby Rhodolite', NULL, false, '["Perfume","Creme"]'::jsonb, NULL),
  (92, 'lauv-green', 'Lauv Green', 'like', false, '["Perfume"]'::jsonb, 'Masc'),
  (93, 'my-we-belle', 'My We Belle', NULL, false, '["Perfume"]'::jsonb, NULL),
  (94, 'verano-di-capri', 'Verano Di Capri', 'like', false, '["Perfume"]'::jsonb, NULL),
  (95, 'latina', 'Latina', NULL, false, '["Perfume"]'::jsonb, NULL),
  (96, 'eternal-cherish', 'Eternal Cherish', NULL, false, '["Perfume"]'::jsonb, NULL),
  (97, 'velours-pourpre', 'Velours Pourpre', NULL, false, '["Perfume"]'::jsonb, NULL),
  (98, 'cassera', 'Cassera', NULL, false, '["Perfume"]'::jsonb, NULL),
  (99, 'ever-strong', 'Ever Strong', NULL, false, '["Perfume"]'::jsonb, NULL),
  (100, 'castillo', 'Castillo', NULL, false, '["Perfume"]'::jsonb, NULL),
  (101, 'elowen', 'Elowen', 'dislike', false, '["Perfume"]'::jsonb, NULL);
