/**
 * Dev seed for the home marketplace feed.
 *
 * Inserts a small, realistic set of home_sections / home_cards rows so
 * `GET /home/sections` returns real database rows alongside the Flutter-side
 * demo fallback. Safe to run repeatedly:
 *
 *  - Section and card rows use fixed UUIDs, so re-runs upsert in place.
 *  - Orphaned cards under seed sections (from a previous seed run with a
 *    different card set) are removed before inserting.
 *  - Only rows carrying the fixed seed UUIDs / titles are touched; any other
 *    data in the tables is left alone.
 *
 * Run:  npm run seed:home     (from backend/)
 *
 * Tables must already exist — start the backend once first (TypeORM
 * synchronize creates them in non-production environments).
 */
require('dotenv').config();

const { Client } = require('pg');

const SEED_SECTIONS = [
  {
    id: '00000000-0000-4000-8000-000000000001',
    title: 'Recommended for you',
    subtitle: 'Hand-picked stays and flights this week',
    layout: 'horizontalPeek',
    order: 1,
  },
  {
    id: '00000000-0000-4000-8000-000000000002',
    title: 'Trending destinations',
    subtitle: 'Where travellers are heading now',
    layout: 'grid',
    order: 2,
  },
  {
    id: '00000000-0000-4000-8000-000000000003',
    title: 'Tour packages',
    subtitle: 'Everything arranged, just pack',
    layout: 'horizontal',
    order: 3,
  },
  {
    id: '00000000-0000-4000-8000-000000000004',
    title: 'Experiences & stories',
    subtitle: 'Ideas for your next trip',
    layout: 'vertical',
    order: 4,
  },
];

const SEED_CARDS = [
  // Recommended for you
  card('00000000-0000-4000-8000-0000000101', 1, 'hotel', {
    title: 'Grand Palm Hotel', subtitle: 'Paris, France',
    price: 320, currency: 'USD', rating: 4.6, reviewCount: 214,
    badge: 'Popular', tags: ['4-star', 'City center'],
    imageUrl: 'https://picsum.photos/seed/grand-palm/400/300',
  }),
  card('00000000-0000-4000-8000-0000000102', 2, 'flight', {
    title: 'Cairo → Istanbul', subtitle: 'Round trip · 7 days',
    price: 289, currency: 'USD', rating: 4.4, reviewCount: 96,
    badge: 'Deal', tags: ['Direct', 'Economy'],
  }),
  card('00000000-0000-4000-8000-0000000103', 3, 'deal', {
    title: 'Weekend in Alexandria', subtitle: 'Hotel + breakfast included',
    price: 145, currency: 'USD', rating: 4.2, reviewCount: 58, badge: '-30%',
  }),
  // Trending destinations
  card('00000000-0000-4000-8000-0000000201', 1, 'destination', {
    title: 'Istanbul', subtitle: 'Turkey',
    description: 'Bridges, bazaars and Bosphorus views.',
    imageUrl: 'https://picsum.photos/seed/istanbul-view/400/300',
  }, 2),
  card('00000000-0000-4000-8000-0000000202', 2, 'destination', {
    title: 'Dubai', subtitle: 'UAE',
    description: 'Skyline dining and desert adventures.',
    imageUrl: 'https://picsum.photos/seed/dubai-skyline/400/300',
  }, 2),
  card('00000000-0000-4000-8000-0000000203', 3, 'destination', {
    title: 'Rome', subtitle: 'Italy',
    description: 'Ancient streets and unforgettable food.',
    imageUrl: 'https://picsum.photos/seed/rome-streets/400/300',
  }, 2),
  // Tour packages
  card('00000000-0000-4000-8000-0000000301', 1, 'package', {
    title: 'Sharm El Sheikh · 5 days', subtitle: 'Flights + resort + transfers',
    price: 599, currency: 'USD', rating: 4.7, reviewCount: 132,
    highlights: ['All inclusive', 'Airport transfer'],
    imageUrl: 'https://picsum.photos/seed/sharm-resort/400/300',
  }, 3),
  card('00000000-0000-4000-8000-0000000302', 2, 'package', {
    title: 'Luxor & Aswan cruise · 4 nights', subtitle: 'Nile cruise with guided tours',
    price: 749, currency: 'USD', rating: 4.8, reviewCount: 87,
    highlights: ['Guided temples', 'Full board'],
  }, 3),
  // Experiences & stories
  card('00000000-0000-4000-8000-0000000401', 1, 'experience', {
    title: 'Sunset felucca ride', subtitle: 'Aswan, Egypt',
    price: 25, currency: 'USD', rating: 4.9, reviewCount: 41,
    imageUrl: 'https://picsum.photos/seed/felucca-sunset/400/300',
  }, 4),
  card('00000000-0000-4000-8000-0000000402', 2, 'story', {
    title: '48 hours in old Cairo', subtitle: 'Community story',
    description: 'Khan el-Khalili, hidden cafés and the citadel at dusk.',
  }, 4),
];

function card(id, order, cardType, content, sectionIndex = 1) {
  return {
    id,
    sectionId: SEED_SECTIONS[sectionIndex - 1].id,
    cardType,
    order,
    content,
  };
}

async function main() {
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 5432),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  try {
    await client.connect();
  } catch {
    console.error('Seed aborted: could not connect to the database.');
    console.error('Check DB_* settings in backend/.env and that Postgres is running.');
    process.exit(1);
  }

  try {
    const sectionIds = SEED_SECTIONS.map((s) => s.id);
    const cardIds = SEED_CARDS.map((c) => c.id);

    // Upsert sections (fixed UUIDs → idempotent).
    for (const s of SEED_SECTIONS) {
      await client.query(
        `INSERT INTO home_sections (id, title, subtitle, layout, "order", is_visible)
         VALUES ($1, $2, $3, $4, $5, true)
         ON CONFLICT (id) DO UPDATE SET
           title = EXCLUDED.title,
           subtitle = EXCLUDED.subtitle,
           layout = EXCLUDED.layout,
           "order" = EXCLUDED."order",
           is_visible = true,
           updated_at = now()`,
        [s.id, s.title, s.subtitle, s.layout, s.order],
      );
    }

    // Remove orphaned cards from earlier seed runs under seed sections.
    await client.query(
      `DELETE FROM home_cards WHERE section_id = ANY($1::uuid[]) AND id <> ALL($2::uuid[])`,
      [sectionIds, cardIds],
    );

    // Upsert cards.
    for (const c of SEED_CARDS) {
      await client.query(
        `INSERT INTO home_cards (id, section_id, card_type, content, "order", is_visible)
         VALUES ($1, $2, $3, $4::jsonb, $5, true)
         ON CONFLICT (id) DO UPDATE SET
           section_id = EXCLUDED.section_id,
           card_type = EXCLUDED.card_type,
           content = EXCLUDED.content,
           "order" = EXCLUDED."order",
           is_visible = true,
           updated_at = now()`,
        [c.id, c.sectionId, c.cardType, JSON.stringify(c.content), c.order],
      );
    }

    const counts = await client.query(
      `SELECT
         (SELECT count(*) FROM home_sections WHERE id = ANY($1::uuid[])) AS sections,
         (SELECT count(*) FROM home_cards WHERE id = ANY($2::uuid[])) AS cards`,
      [sectionIds, cardIds],
    );
    console.log(
      `Home seed complete: ${counts.rows[0].sections} sections, ${counts.rows[0].cards} cards.`,
    );
  } catch (err) {
    if (err && err.code === '42P01') {
      console.error('Seed aborted: home_sections/home_cards tables do not exist yet.');
      console.error('Start the backend once (npm run start:dev) so TypeORM creates them, then re-run.');
    } else {
      console.error('Seed failed:', err.message || err);
    }
    process.exitCode = 1;
  } finally {
    try { await client.end(); } catch (_) { /* ignore */ }
  }
}

main();
