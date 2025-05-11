from sqlalchemy import create_engine, MetaData, Table, select
from supabase import create_client, Client
from dotenv import load_dotenv
import os

# --- Load environment variables ---
load_dotenv()

DB_USER = os.getenv("MARIADB_USER", "wp_user")
DB_PASS = os.getenv("MARIADB_PASSWORD", "EvenStrongerUserPwd456!")
DB_HOST = os.getenv("WORDPRESS_DB_HOST", "db")
DB_NAME = os.getenv("MARIADB_DATABASE", "wordpress")
WP_DB_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:3306/{DB_NAME}"

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# --- Init ---
engine = create_engine(WP_DB_URL)
metadata = MetaData()
metadata.reflect(bind=engine)

wp_posts = Table("wp_posts", metadata, autoload_with=engine)
wp_postmeta = Table("wp_postmeta", metadata, autoload_with=engine)
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_post_meta(conn, post_id):
    rows = conn.execute(
        select(wp_postmeta.c.meta_key, wp_postmeta.c.meta_value)
        .where(wp_postmeta.c.post_id == post_id)
    ).fetchall()
    return {row[0]: row[1] for row in rows}

with engine.connect() as conn:
    players = conn.execute(
        select(wp_posts)
        .where(wp_posts.c.post_type == 'sp_player')
        .where(wp_posts.c.post_status == 'publish')
    ).fetchall()

    for player in players:
        meta = get_post_meta(conn, player.id)
        stats = {k: meta[k] for k in meta if k.isupper()}
        team_wp_id = int(meta['sp_team'][0]) if 'sp_team' in meta and meta['sp_team'] else None

        team_id = None
        if team_wp_id:
            res = supabase.table("teams").select("id").eq("wp_id", team_wp_id).execute()
            if res.data:
                team_id = res.data[0]['id']

        supabase.table("players").upsert({
            "wp_id": player.id,
            "name": player.post_title,
            "team_wp_id": team_wp_id,
            "team_id": team_id,
            "stats": stats,
        }, on_conflict=["wp_id"]).execute()

print("✅ Player sync complete.")
