<?php
/**
 * Plugin Name: Bodega Sync Control
 * Description: Admin controls to manually trigger sync_players.py and sync_teams.py
 * Version: 1.0
 * Author: Bodega Cats GC
 */

add_action('admin_menu', 'bodega_sync_control_menu');

function bodega_sync_control_menu() {
    add_menu_page(
        'Bodega Sync',
        'Bodega Sync',
        'manage_options',
        'bodega-sync-control',
        'bodega_sync_control_page',
        'dashicons-update',
        100
    );
}

function bodega_sync_control_page() {
    echo '<div class="wrap"><h1>Bodega Sync Control</h1>';

    if (isset($_POST['sync_players'])) {
        echo '<p><strong>Running Player Sync...</strong></p>';
        $output = shell_exec('/opt/bitnami/venv/bin/python3 /opt/bitnami/scripts/sync_players.py 2>&1');
        echo '<pre>' . esc_html($output) . '</pre>';
    }

    if (isset($_POST['sync_teams'])) {
        echo '<p><strong>Running Team Sync...</strong></p>';
        $output = shell_exec('/opt/bitnami/venv/bin/python3 /opt/bitnami/scripts/sync_teams.py 2>&1');
        echo '<pre>' . esc_html($output) . '</pre>';
    }

    echo '<form method="post">';
    submit_button('Sync Players', 'primary', 'sync_players');
    submit_button('Sync Teams', 'secondary', 'sync_teams');
    echo '</form></div>';
}
