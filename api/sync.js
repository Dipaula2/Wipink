

const VTEX_CATEGORY = 'perfumaria'; // categoria de perfumes na WePink
const SB  = process.env.SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_KEY;

// mesmo slug usado no banco (precisa bater certinho)
const slugify = s => (s || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '')
  .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

// "VF Golden Desodorante Colônia 75ml - Wepink"  ->  "VF Golden"
function extractName(pn) {
  return (pn || '')
    .replace(/\s*-\s*we\s*pink\s*$/i, '')
    .replace(/desodorante\s+col[oô]nia/ig, ' ')
    .replace(/eau\s+de\s+parfum/ig, ' ')
    .replace(/body\s+splash/ig, ' ')
    .replace(/\bcol[oô]nia\b/ig, ' ')
    .replace(/\b\d+\s*ml\b/ig, ' ')
    .replace(/\s{2,}/g, ' ')
    .trim();
}

// Deixa a imagem menor/mais leve (melhor p/ celular): pede ~500px na CDN da VTEX
function resize(url) {
  if (!url) return url;
  return url.replace(/\/arquivos\/ids\/(\d+)(-\d+-\w+)?/i, '/arquivos/ids/$1-500-500');
}

// ---------- WePink (VTEX) ----------
async function fetchWePink() {
  const out = [];
  const PAGE = 50;
  for (let from = 0; from < 400; from += PAGE) {
    const to = from + PAGE - 1;
    const url = `https://www.wepink.com.br/api/catalog_system/pub/products/search/${VTEX_CATEGORY}?_from=${from}&_to=${to}`;
    let arr;
    try {
      const r = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0', 'Accept': 'application/json' } });
      if (!r.ok) break;
      arr = await r.json();
    } catch (e) { break; }
    if (!Array.isArray(arr) || arr.length === 0) break;
    for (const p of arr) {
      const name = extractName(p.productName || '');
      if (!name) continue;
      const item = (p.items || [])[0] || {};
      const img  = (item.images || [])[0] || {};
      out.push({
        slug: slugify(name),
        name,
        photo_url: resize(img.imageUrl) || null,
        vtex_link: p.link || (p.linkText ? `https://www.wepink.com.br/${p.linkText}/p` : null),
      });
    }
    if (arr.length < PAGE) break;
  }
  // remove duplicados por slug (mantém o que tiver foto)
  const map = new Map();
  for (const it of out) {
    if (!map.has(it.slug) || (!map.get(it.slug).photo_url && it.photo_url)) map.set(it.slug, it);
  }
  return [...map.values()];
}

// ---------- Supabase (REST) ----------
// Chaves NOVAS (sb_secret_...) não são JWT: vão SÓ no header "apikey".
// Chave LEGADA (service_role, começa com "ey") precisa também do "Authorization: Bearer".
const IS_JWT = !!KEY && KEY.startsWith('ey');
const sbHeaders = extra => {
  const h = { apikey: KEY, 'Content-Type': 'application/json', ...extra };
  if (IS_JWT) h.Authorization = `Bearer ${KEY}`;
  return h;
};

async function existingSlugs() {
  const r = await fetch(`${SB}/rest/v1/perfumes?select=slug`, { headers: sbHeaders() });
  if (!r.ok) return new Set();
  const rows = await r.json();
  return new Set(rows.map(x => x.slug));
}

async function upsert(payload) {
  if (!payload.length) return;
  const r = await fetch(`${SB}/rest/v1/perfumes?on_conflict=slug`, {
    method: 'POST',
    headers: sbHeaders({ Prefer: 'resolution=merge-duplicates,return=minimal' }),
    body: JSON.stringify(payload),
  });
  if (!r.ok) throw new Error('Supabase ' + r.status + ': ' + (await r.text()));
}

// ---------- Handler ----------
module.exports = async (req, res) => {
  try {
    if (!SB || !KEY) {
      return res.status(500).json({ error: 'Configure SUPABASE_URL e SUPABASE_SERVICE_KEY nas variáveis de ambiente da Vercel.' });
    }
    const products = await fetchWePink();
    if (!products.length) {
      return res.status(502).json({ error: 'Nenhum produto recebido da WePink (a API pode ter mudado).' });
    }
    const have = await existingSlugs();
    const novos = products.filter(p => !have.has(p.slug)).length;

    // Um único upsert, com 'name' em TODAS as linhas (a coluna é obrigatória):
    //  - slug já existente -> atualiza nome/foto/link (mantém curtidas, "tenho", produtos e ordem)
    //  - slug novo         -> entra como "a avaliar" no fim da lista
    const payload = products.map(p => ({
      slug: p.slug, name: p.name, photo_url: p.photo_url, vtex_link: p.vtex_link,
    }));
    await upsert(payload);

    return res.status(200).json({ ok: true, total: products.length, novos, fotos: products.length - novos });
  } catch (e) {
    return res.status(500).json({ error: String((e && e.message) || e) });
  }
};
