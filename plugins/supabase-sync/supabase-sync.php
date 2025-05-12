<?php
/**
 * Plugin Name: Supabase Sync
 * Description: Manually trigger sync scripts from WordPress to Supabase.
 * Version: 1.0
 * Author: Bodega Cats GC
 */

add_action('admin_menu', 'supabase_sync_menu');

function supabase_sync_menu() {
    add_menu_page(
        'Supabase Sync',
        'Supabase Sync',
        'manage_options',
        'supabase-sync',
        'supabase_sync_admin_page',
        'dashicons-cloud',
        100
    );
}

function supabase_sync_admin_page() {
    echo '<div class="wrap"><h1>Supabase Sync</h1>';

    if (isset($_POST['sync_now'])) {
        echo '<p><strong>Running sync...</strong></p>';

        // Example sync command (adjust paths if needed)
        $output = shell_exec('/opt/bitnami/venv/bin/python3 /opt/bitnami/scripts/sync_players.py 2>&1');
        echo '<pre>' . esc_html($output) . '</pre>';
    }

    echo '<form method="post">';
    submit_button('Sync Players Now', 'primary', 'sync_now');
    echo '</form></div>';
}
