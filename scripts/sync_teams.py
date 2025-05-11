from sqlalchemy import create_engine, MetaData, Table, select
from supabase import create_client, Client
from dotenv import load_dotenv
import os

# --- Load environment variables ---
load_dotenv()

# MariaDB connection from .env
DB_USER = os.getenv("MARIADB_USER", "wp_user")
DB_PASS = os.getenv("MARIADB_PASSWORD", "EvenStrongerUserPwd456!")
DB_HOST = os.getenv("WORDPRESS_DB_HOST", "db")
DB_NAME = os.getenv("MARIADB_DATABASE", "wordpress")
WP_DB_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:3306/{DB_NAME}"

# Supabase
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# --- Init ---
engine = create_engine(WP_DB_URL)
metadata = MetaData()
metadata.reflect(bind=engine)

wp_posts = Table("wp_posts", metadata, autoload_with=engine)
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

with engine.connect() as conn:
    teams = conn.execute(
        select(wp_posts)
        .where(wp_posts.c.post_type == 'sp_team')
        .where(wp_posts.c.post_status == 'publish')
    ).fetchall()

    for team in teams:
        supabase.table("teams").upsert({
            "wp_id": team.id,
            "name": team.post_title,
        }, on_conflict=["wp_id"]).execute()

print("✅ Team sync complete.")
