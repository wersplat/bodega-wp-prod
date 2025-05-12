<?php
/*
Plugin Name: Supabase Sync
*/

function supabase_sync($post_id) {
    $post = get_post($post_id);
    $payload = json_encode([
        'id' => $post->ID,
        'title' => $post->post_title,
        'content' => $post->post_content,
        'type' => $post->post_type,
        'status' => $post->post_status,
        'modified' => $post->post_modified,
    ]);

    wp_remote_post('https://api.bodegacatsgc.gg/wp-sync', [
        'method' => 'POST',
        'headers' => [
            'Content-Type' => 'application/json',
            'X-API-KEY' => '<your-secure-api-key>',
        ],
        'body' => $payload
    ]);
}

add_action('save_post', 'supabase_sync');

// SportsPress-specific hooks
add_action('sports_press_match_saved', 'supabase_sync');
add_action('sports_press_roster_updated', 'supabase_sync');
?>