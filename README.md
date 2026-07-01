# 🩷 Minha Coleção WePink — guia de instalação

Um site pra catalogar os perfumes da WePink como uma lista de compras: **buscar**, **curtir (❤️)**, **descurtir (💔)** e marcar **“já tenho” (✅)** — agora com as **fotos reais puxadas da WePink** e **atualização automática** quando lançam perfume novo.

Já vem com os **101 perfumes** da sua lista preenchidos (57 curtidos, 21 descartados, 16 que você tem, 23 a avaliar).

---

## 📁 Arquivos da pasta

- **`index.html`** → o site.
- **`supabase.sql`** → cria a tabela e insere os perfumes no banco.
- **`api/sync.js`** → o “robô” que vai na WePink buscar fotos e lançamentos novos. **Tem que ficar dentro de uma pasta chamada `api`.**
- **`vercel.json`** → agenda o robô pra rodar 1x por dia, sozinho.
- **`README.md`** → este guia.

> Abrindo o `index.html` direto no navegador ele já funciona em **modo demonstração** (dá pra clicar nos corações, mas não salva e sem fotos reais). As fotos e o automático só ligam depois de publicado.

---

## Passo 1 — Banco de dados (Supabase) · ~5 min

1. Crie conta grátis em **supabase.com** → **New project** (dê um nome e uma senha). Espere ~1 min.
2. Menu **SQL Editor** → **New query**. Cole **todo** o conteúdo do **`supabase.sql`** e clique em **Run**. Deve dar “Success”.
3. Pegue as chaves em **Settings (engrenagem) → API Keys**. Você vai precisar de **três** coisas:
   - **Project URL** (`https://xxxxx.supabase.co`) — fica em **Settings → API** ou no botão **Connect**.
   - **Publishable key** (`sb_publishable_...`) → a "pública", pode aparecer no site.
   - **Secret key** (`sb_secret_...`) ⚠️ **(SECRETA — nunca coloque no site nem no GitHub!)** — na seção "Secret keys", clique no olhinho 👁️ pra revelar e copiar.

   *(Se o seu painel ainda mostrar a aba antiga "Legacy anon, service_role", pode usar a `anon` no lugar da publishable e a `service_role` no lugar da secret — o robô funciona com as duas versões.)*

---

## Passo 2 — Colar as chaves no site · ~1 min

1. Abra o **`index.html`** num editor de texto.
2. No comecinho do `<script>` troque estas duas linhas pelas SUAS chaves **pública**:

   ```js
   const SUPABASE_URL = "COLE_SUA_PROJECT_URL_AQUI";
   const SUPABASE_ANON_KEY = "COLE_SUA_ANON_PUBLIC_KEY_AQUI";
   ```

   *(Aqui é a **Publishable key** — `sb_publishable_...`. A Secret vai em outro lugar, no Passo 4.)*

---

## Passo 3 — Colocar no ar (Vercel) · ~5 min

1. Crie conta no **github.com**. Em **New repository**, dê um nome (ex.: `wepink`) e crie.
   - ⚠️ Crie o repositório **na sua conta pessoal** (não dentro de uma “organização”) — o plano grátis da Vercel não conecta repositórios de organização.
2. **Add file → Upload files** e suba os arquivos **mantendo a pasta `api`** (arraste a pasta inteira). Confirme em **Commit changes**.
3. Crie conta no **vercel.com** (entre com o GitHub) → **Add New… → Project** → escolha o repositório `wepink` → **Deploy**.
4. Em ~30s sai o link do seu site, tipo `https://wepink.vercel.app`. 🎉

> A faixa no topo do site deve ficar **verde** (“Conectado ao Supabase”). As fotos ainda não aparecem — isso é o próximo passo.

---

## Passo 4 — Ligar as FOTOS e o AUTOMÁTICO · ~3 min

1. Na Vercel, abra seu projeto → **Settings → Environment Variables**. Adicione **duas** variáveis:
   - `SUPABASE_URL` → a mesma Project URL do Passo 1
   - `SUPABASE_SERVICE_KEY` → a chave **Secret** (`sb_secret_...`)  — *(ou a `service_role` se você usar a aba Legacy)*
2. Salve e vá em **Deployments → ⋯ → Redeploy** (pra valer as variáveis).
3. Abra seu site e clique no botão **“Buscar novos perfumes na WePink”**. Em alguns segundos as **fotos reais** aparecem. ✨

Pronto: a partir daí o site se atualiza **sozinho 1x por dia** (graças ao `vercel.json`), e sempre que lançar perfume novo na WePink ele entra aqui como **“a avaliar”**. Você também pode clicar no botão quando quiser forçar a atualização.

---

## 🔒 Segurança (rapidinho)

- A chave **Secret (`sb_secret_...`) é secreta**: ela só pode existir nas variáveis de ambiente da Vercel. Nunca cole no `index.html` nem suba no GitHub. (O Supabase inclusive **cancela automaticamente** chaves secretas que detecta em repositórios públicos do GitHub — então cuidado pra não subir junto.)
- O site não tem login: quem tem o link vê e edita a lista. Pra uso pessoal costuma ser ok. Quer deixar **privado** ou **multiusuário** (cada um com a sua lista)? Me chama que eu adiciono login.

---

## 🛠️ Problemas comuns

- **Faixa amarela (“modo demonstração”)** → as chaves públicas do Passo 2 não foram coladas certo.
- **Faixa rosa (“tabela vazia”)** → faltou rodar o `supabase.sql` (Passo 1.2).
- **Botão dá erro** → confira as 2 variáveis do Passo 4 e se você fez o **Redeploy**. O robô precisa da chave **Secret** (`sb_secret_...`).
- **Apareceram perfumes repetidos depois de sincronizar** → acontece quando o nome na sua lista está escrito diferente do oficial da WePink (ex.: “Obssesed” × “Obsessed”). É só apagar o repetido no Supabase — ou me mandar quais são que eu ajusto os nomes pra casarem.
- **Trocar foto manualmente** → passe o mouse no card → botão **“foto”** → cole o link de uma imagem.

Qualquer dúvida, é só chamar. 🩷
