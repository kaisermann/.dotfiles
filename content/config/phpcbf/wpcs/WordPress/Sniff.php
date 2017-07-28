<?php
/**
 * Represents a PHP_CodeSniffer sniff for sniffing WordPress coding standards.
 *
 * @package WPCS\WordPressCodingStandards
 * @link    https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards
 * @license https://opensource.org/licenses/MIT MIT
 */

/**
 * Represents a PHP_CodeSniffer sniff for sniffing WordPress coding standards.
 *
 * Provides a bootstrap for the sniffs, to reduce code duplication.
 *
 * @package WPCS\WordPressCodingStandards
 * @since   0.4.0
 *
 * {@internal This class contains numerous properties where the array format looks
 *            like `'string' => true`, i.e. the array item is set as the array key.
 *            This allows for sniffs to verify whether something is in one of these
 *            lists using `isset()` rather than `in_array()` which is a much more
 *            efficient (faster) check to execute and therefore improves the
 *            performance of the sniffs.
 *            The `true` value in those cases is used as a placeholder and has no
 *            meaning in and of itself.
 *            In the rare few cases where the array values *do* have meaning, this
 *            is documented in the property documentation.}}
 */
abstract class WordPress_Sniff implements PHP_CodeSniffer_Sniff {

	/**
	 * List of the functions which verify nonces.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $nonceVerificationFunctions = array(
		'wp_verify_nonce'     => true,
		'check_admin_referer' => true,
		'check_ajax_referer'  => true,
	);

	/**
	 * Functions that escape values for display.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $escapingFunctions = array(
		'absint'               => true,
		'esc_attr__'           => true,
		'esc_attr_e'           => true,
		'esc_attr_x'           => true,
		'esc_attr'             => true,
		'esc_html__'           => true,
		'esc_html_e'           => true,
		'esc_html_x'           => true,
		'esc_html'             => true,
		'esc_js'               => true,
		'esc_sql'              => true,
		'esc_textarea'         => true,
		'esc_url_raw'          => true,
		'esc_url'              => true,
		'filter_input'         => true,
		'filter_var'           => true,
		'floatval'             => true,
		'intval'               => true,
		'json_encode'          => true,
		'like_escape'          => true,
		'number_format'        => true,
		'rawurlencode'         => true,
		'sanitize_html_class'  => true,
		'sanitize_user_field'  => true,
		'tag_escape'           => true,
		'urlencode_deep'       => true,
		'urlencode'            => true,
		'wp_json_encode'       => true,
		'wp_kses_allowed_html' => true,
		'wp_kses_data'         => true,
		'wp_kses_post'         => true,
		'wp_kses'              => true,
	);

	/**
	 * Functions whose output is automatically escaped for display.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $autoEscapedFunctions = array(
		'allowed_tags'              => true,
		'bloginfo'                  => true,
		'body_class'                => true,
		'calendar_week_mod'         => true,
		'cancel_comment_reply_link' => true,
		'category_description'      => true,
		'checked'                   => true,
		'comment_author_email_link' => true,
		'comment_author_email'      => true,
		'comment_author_IP'         => true,
		'comment_author_link'       => true,
		'comment_author_rss'        => true,
		'comment_author_url_link'   => true,
		'comment_author_url'        => true,
		'comment_author'            => true,
		'comment_class'             => true,
		'comment_date'              => true,
		'comment_excerpt'           => true,
		'comment_form_title'        => true,
		'comment_form'              => true,
		'comment_id_fields'         => true,
		'comment_ID'                => true,
		'comment_reply_link'        => true,
		'comment_text_rss'          => true,
		'comment_text'              => true,
		'comment_time'              => true,
		'comment_type'              => true,
		'comments_link'             => true,
		'comments_number'           => true,
		'comments_popup_link'       => true,
		'comments_popup_script'     => true,
		'comments_rss_link'         => true,
		'count'                     => true,
		'delete_get_calendar_cache' => true,
		'disabled'                  => true,
		'do_shortcode'              => true,
		'do_shortcode_tag'          => true,
		'edit_bookmark_link'        => true,
		'edit_comment_link'         => true,
		'edit_post_link'            => true,
		'edit_tag_link'             => true,
		'get_archives_link'         => true,
		'get_attachment_link'       => true,
		'get_avatar'                => true,
		'get_bookmark_field'        => true,
		'get_bookmark'              => true,
		'get_calendar'              => true,
		'get_comment_author_link'   => true,
		'get_comment_date'          => true,
		'get_comment_time'          => true,
		'get_current_blog_id'       => true,
		'get_delete_post_link'      => true,
		'get_footer'                => true,
		'get_header'                => true,
		'get_search_form'           => true,
		'get_search_query'          => true,
		'get_sidebar'               => true,
		'get_template_part'         => true,
		'get_the_author_link'       => true,
		'get_the_author'            => true,
		'get_the_date'              => true,
		'get_the_ID'                => true,
		'get_the_post_thumbnail'    => true,
		'get_the_term_list'         => true,
		'get_the_title'             => true,
		'has_post_thumbnail'        => true,
		'is_attachment'             => true,
		'next_comments_link'        => true,
		'next_image_link'           => true,
		'next_post_link'            => true,
		'next_posts_link'           => true,
		'paginate_comments_links'   => true,
		'permalink_anchor'          => true,
		'post_password_required'    => true,
		'post_type_archive_title'   => true,
		'posts_nav_link'            => true,
		'previous_comments_link'    => true,
		'previous_image_link'       => true,
		'previous_post_link'        => true,
		'previous_posts_link'       => true,
		'selected'                  => true,
		'single_cat_title'          => true,
		'single_month_title'        => true,
		'single_post_title'         => true,
		'single_tag_title'          => true,
		'single_term_title'         => true,
		'sticky_class'              => true,
		'tag_description'           => true,
		'term_description'          => true,
		'the_attachment_link'       => true,
		'the_author_link'           => true,
		'the_author_meta'           => true,
		'the_author_posts_link'     => true,
		'the_author_posts'          => true,
		'the_author'                => true,
		'the_category_rss'          => true,
		'the_category'              => true,
		'the_content_rss'           => true,
		'the_content'               => true,
		'the_date_xml'              => true,
		'the_date'                  => true,
		'the_excerpt_rss'           => true,
		'the_excerpt'               => true,
		'the_feed_link'             => true,
		'the_ID'                    => true,
		'the_meta'                  => true,
		'the_modified_author'       => true,
		'the_modified_date'         => true,
		'the_modified_time'         => true,
		'the_permalink'             => true,
		'the_post_thumbnail'        => true,
		'the_search_query'          => true,
		'the_shortlink'             => true,
		'the_tags'                  => true,
		'the_taxonomies'            => true,
		'the_terms'                 => true,
		'the_time'                  => true,
		'the_title_attribute'       => true,
		'the_title_rss'             => true,
		'the_title'                 => true,
		'vip_powered_wpcom'         => true,
		'walk_nav_menu_tree'        => true,
		'wp_attachment_is_image'    => true,
		'wp_dropdown_categories'    => true,
		'wp_dropdown_users'         => true,
		'wp_enqueue_script'         => true,
		'wp_generate_tag_cloud'     => true,
		'wp_get_archives'           => true,
		'wp_get_attachment_image'   => true,
		'wp_get_attachment_link'    => true,
		'wp_link_pages'             => true,
		'wp_list_authors'           => true,
		'wp_list_bookmarks'         => true,
		'wp_list_categories'        => true,
		'wp_list_comments'          => true,
		'wp_login_form'             => true,
		'wp_loginout'               => true,
		'wp_meta'                   => true,
		'wp_nav_menu'               => true,
		'wp_register'               => true,
		'wp_shortlink_header'       => true,
		'wp_shortlink_wp_head'      => true,
		'wp_tag_cloud'              => true,
		'wp_title'                  => true,
	);

	/**
	 * Functions that sanitize values.
	 *
	 * This list is complementary to the `$unslashingSanitizingFunctions`
	 * list.
	 * Sanitizing functions should be added to this list if they do *not*
	 * implicitely unslash data and to the `$unslashingsanitizingFunctions`
	 * list if they do.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $sanitizingFunctions = array(
		'_wp_handle_upload'          => true,
		'array_key_exists'           => true,
		'esc_url_raw'                => true,
		'filter_input'               => true,
		'filter_var'                 => true,
		'hash_equals'                => true,
		'in_array'                   => true,
		'is_email'                   => true,
		'number_format'              => true,
		'sanitize_bookmark_field'    => true,
		'sanitize_bookmark'          => true,
		'sanitize_email'             => true,
		'sanitize_file_name'         => true,
		'sanitize_hex_color_no_hash' => true,
		'sanitize_hex_color'         => true,
		'sanitize_html_class'        => true,
		'sanitize_meta'              => true,
		'sanitize_mime_type'         => true,
		'sanitize_option'            => true,
		'sanitize_sql_orderby'       => true,
		'sanitize_term_field'        => true,
		'sanitize_term'              => true,
		'sanitize_text_field'        => true,
		'sanitize_textarea_field'    => true,
		'sanitize_title_for_query'   => true,
		'sanitize_title_with_dashes' => true,
		'sanitize_title'             => true,
		'sanitize_user_field'        => true,
		'sanitize_user'              => true,
		'validate_file'              => true,
		'wp_handle_sideload'         => true,
		'wp_handle_upload'           => true,
		'wp_kses_allowed_html'       => true,
		'wp_kses_data'               => true,
		'wp_kses_post'               => true,
		'wp_kses'                    => true,
		'wp_parse_id_list'           => true,
		'wp_redirect'                => true,
		'wp_safe_redirect'           => true,
		'wp_strip_all_tags'          => true,
	);

	/**
	 * Sanitizing functions that implicitly unslash the data passed to them.
	 *
	 * This list is complementary to the `$sanitizingFunctions` list.
	 * Sanitizing functions should be added to this list if they also
	 * implicitely unslash data and to the `$sanitizingFunctions` list
	 * if they don't.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $unslashingSanitizingFunctions = array(
		'absint'       => true,
		'boolval'      => true,
		'floatval'     => true,
		'intval'       => true,
		'is_array'     => true,
		'sanitize_key' => true,
	);

	/**
	 * Functions that format strings.
	 *
	 * These functions are often used for formatting values just before output, and
	 * it is common practice to escape the individual parameters passed to them as
	 * needed instead of escaping the entire result. This is especially true when the
	 * string being formatted contains HTML, which makes escaping the full result
	 * more difficult.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $formattingFunctions = array(
		'array_fill' => true,
		'ent2ncr'    => true,
		'implode'    => true,
		'join'       => true,
		'nl2br'      => true,
		'sprintf'    => true,
		'vsprintf'   => true,
		'wp_sprintf' => true,
	);

	/**
	 * Functions which print output incorporating the values passed to them.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $printingFunctions = array(
		'_deprecated_argument'    => true,
		'_deprecated_constructor' => true,
		'_deprecated_file'        => true,
		'_deprecated_function'    => true,
		'_deprecated_hook'        => true,
		'_doing_it_wrong'         => true,
		'_e'                      => true,
		'_ex'                     => true,
		'die'                     => true,
		'echo'                    => true,
		'exit'                    => true,
		'print'                   => true,
		'printf'                  => true,
		'trigger_error'           => true,
		'user_error'              => true,
		'vprintf'                 => true,
		'wp_die'                  => true,
		'wp_dropdown_pages'       => true,
	);

	/**
	 * Functions that escape values for use in SQL queries.
	 *
	 * @since 0.9.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $SQLEscapingFunctions = array(
		'absint'      => true,
		'esc_sql'     => true,
		'floatval'    => true,
		'intval'      => true,
		'like_escape' => true,
	);

	/**
	 * Functions whose output is automatically escaped for use in SQL queries.
	 *
	 * @since 0.9.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $SQLAutoEscapedFunctions = array(
		'count' => true,
	);

	/**
	 * A list of functions that get data from the cache.
	 *
	 * @since 0.6.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $cacheGetFunctions = array(
		'wp_cache_get' => true,
	);

	/**
	 * A list of functions that set data in the cache.
	 *
	 * @since 0.6.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $cacheSetFunctions = array(
		'wp_cache_set' => true,
		'wp_cache_add' => true,
	);

	/**
	 * A list of functions that delete data from the cache.
	 *
	 * @since 0.6.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $cacheDeleteFunctions = array(
		'wp_cache_delete' => true,
		'clean_attachment_cache' => true,
		'clean_blog_cache' => true,
		'clean_bookmark_cache' => true,
		'clean_category_cache' => true,
		'clean_comment_cache' => true,
		'clean_network_cache' => true,
		'clean_object_term_cache' => true,
		'clean_page_cache' => true,
		'clean_post_cache' => true,
		'clean_term_cache' => true,
		'clean_user_cache' => true,
	);

	/**
	 * A list of functions that invoke WP hooks (filters/actions).
	 *
	 * @since 0.10.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array
	 */
	protected $hookInvokeFunctions = array(
		'do_action'                => true,
		'do_action_ref_array'      => true,
		'do_action_deprecated'     => true,
		'apply_filters'            => true,
		'apply_filters_ref_array'  => true,
		'apply_filters_deprecated' => true,
	);

	/**
	 * A list of functions that are used to interact with the WP plugins API.
	 *
	 * @since 0.10.0
	 * @since 0.11.0 Changed from public static to protected non-static.
	 *
	 * @var array <string function name> => <int position of the hook name argument in function signature>
	 */
	protected $hookFunctions = array(
		'has_filter'         => 1,
		'add_filter'         => 1,
		'remove_filter'      => 1,
		'remove_all_filters' => 1,
		'doing_filter'       => 1, // Hook name optional.
		'has_action'         => 1,
		'add_action'         => 1,
		'doing_action'       => 1, // Hook name optional.
		'did_action'         => 1,
		'remove_action'      => 1,
		'remove_all_actions' => 1,
		'current_filter'     => 0, // No hook name argument.
	);

	/**
	 * List of global WP variables.
	 *
	 * @since 0.3.0
	 * @since 0.11.0 Changed visibility from public to protected.
	 * @since 0.12.0 Renamed from `$globals` to `$wp_globals` to be more descriptive.
	 * @since 0.12.0 Moved from WordPress_Sniffs_Variables_GlobalVariablesSniff to WordPress_Sniff
	 *
	 * @var array
	 */
	protected $wp_globals = array(
		'_links_add_base'                  => true,
		'_links_add_target'                => true,
		'_menu_item_sort_prop'             => true,
		'_nav_menu_placeholder'            => true,
		'_new_bundled_files'               => true,
		'_old_files'                       => true,
		'_parent_pages'                    => true,
		'_registered_pages'                => true,
		'_updated_user_settings'           => true,
		'_wp_additional_image_sizes'       => true,
		'_wp_admin_css_colors'             => true,
		'_wp_default_headers'              => true,
		'_wp_deprecated_widgets_callbacks' => true,
		'_wp_last_object_menu'             => true,
		'_wp_last_utility_menu'            => true,
		'_wp_menu_nopriv'                  => true,
		'_wp_nav_menu_max_depth'           => true,
		'_wp_post_type_features'           => true,
		'_wp_real_parent_file'             => true,
		'_wp_registered_nav_menus'         => true,
		'_wp_sidebars_widgets'             => true,
		'_wp_submenu_nopriv'               => true,
		'_wp_suspend_cache_invalidation'   => true,
		'_wp_theme_features'               => true,
		'_wp_using_ext_object_cache'       => true,
		'action'                           => true,
		'active_signup'                    => true,
		'admin_body_class'                 => true,
		'admin_page_hooks'                 => true,
		'all_links'                        => true,
		'allowedentitynames'               => true,
		'allowedposttags'                  => true,
		'allowedtags'                      => true,
		'auth_secure_cookie'               => true,
		'authordata'                       => true,
		'avail_post_mime_types'            => true,
		'avail_post_stati'                 => true,
		'blog_id'                          => true,
		'blog_title'                       => true,
		'blogname'                         => true,
		'cat'                              => true,
		'cat_id'                           => true,
		'charset_collate'                  => true,
		'comment'                          => true,
		'comment_alt'                      => true,
		'comment_depth'                    => true,
		'comment_status'                   => true,
		'comment_thread_alt'               => true,
		'comment_type'                     => true,
		'comments'                         => true,
		'compress_css'                     => true,
		'compress_scripts'                 => true,
		'concatenate_scripts'              => true,
		'current_screen'                   => true,
		'current_site'                     => true,
		'current_user'                     => true,
		'currentcat'                       => true,
		'currentday'                       => true,
		'currentmonth'                     => true,
		'custom_background'                => true,
		'custom_image_header'              => true,
		'default_menu_order'               => true,
		'descriptions'                     => true,
		'domain'                           => true,
		'editor_styles'                    => true,
		'error'                            => true,
		'errors'                           => true,
		'EZSQL_ERROR'                      => true,
		'feeds'                            => true,
		'GETID3_ERRORARRAY'                => true,
		'hook_suffix'                      => true,
		'HTTP_RAW_POST_DATA'               => true,
		'id'                               => true,
		'in_comment_loop'                  => true,
		'interim_login'                    => true,
		'is_apache'                        => true,
		'is_chrome'                        => true,
		'is_gecko'                         => true,
		'is_IE'                            => true,
		'is_IIS'                           => true,
		'is_iis7'                          => true,
		'is_macIE'                         => true,
		'is_opera'                         => true,
		'is_safari'                        => true,
		'is_winIE'                         => true,
		'l10n'                             => true,
		'link'                             => true,
		'link_id'                          => true,
		'locale'                           => true,
		'locked_post_status'               => true,
		'lost'                             => true,
		'm'                                => true,
		'map'                              => true,
		'menu'                             => true,
		'menu_order'                       => true,
		'merged_filters'                   => true,
		'mode'                             => true,
		'monthnum'                         => true,
		'more'                             => true,
		'multipage'                        => true,
		'names'                            => true,
		'nav_menu_selected_id'             => true,
		'new_whitelist_options'            => true,
		'numpages'                         => true,
		'one_theme_location_no_menus'      => true,
		'opml'                             => true,
		'order'                            => true,
		'orderby'                          => true,
		'overridden_cpage'                 => true,
		'page'                             => true,
		'paged'                            => true,
		'pagenow'                          => true,
		'pages'                            => true,
		'parent_file'                      => true,
		'pass_allowed_html'                => true,
		'pass_allowed_protocols'           => true,
		'path'                             => true,
		'per_page'                         => true,
		'PHP_SELF'                         => true,
		'phpmailer'                        => true,
		'plugin_page'                      => true,
		'plugins'                          => true,
		'post'                             => true,
		'post_default_category'            => true,
		'post_default_title'               => true,
		'post_ID'                          => true,
		'post_id'                          => true,
		'post_mime_types'                  => true,
		'post_type'                        => true,
		'post_type_object'                 => true,
		'posts'                            => true,
		'preview'                          => true,
		'previouscat'                      => true,
		'previousday'                      => true,
		'previousweekday'                  => true,
		'redir_tab'                        => true,
		'required_mysql_version'           => true,
		'required_php_version'             => true,
		'rnd_value'                        => true,
		'role'                             => true,
		's'                                => true,
		'search'                           => true,
		'self'                             => true,
		'shortcode_tags'                   => true,
		'show_admin_bar'                   => true,
		'sidebars_widgets'                 => true,
		'status'                           => true,
		'submenu'                          => true,
		'submenu_file'                     => true,
		'super_admins'                     => true,
		'tab'                              => true,
		'table_prefix'                     => true,
		'tabs'                             => true,
		'tag'                              => true,
		'targets'                          => true,
		'tax'                              => true,
		'taxnow'                           => true,
		'taxonomy'                         => true,
		'term'                             => true,
		'text_direction'                   => true,
		'theme_field_defaults'             => true,
		'themes_allowedtags'               => true,
		'timeend'                          => true,
		'timestart'                        => true,
		'tinymce_version'                  => true,
		'title'                            => true,
		'totals'                           => true,
		'type'                             => true,
		'typenow'                          => true,
		'updated_timestamp'                => true,
		'upgrading'                        => true,
		'urls'                             => true,
		'user_email'                       => true,
		'user_ID'                          => true,
		'user_identity'                    => true,
		'user_level'                       => true,
		'user_login'                       => true,
		'user_url'                         => true,
		'userdata'                         => true,
		'usersearch'                       => true,
		'whitelist_options'                => true,
		'withcomments'                     => true,
		'wp'                               => true,
		'wp_actions'                       => true,
		'wp_admin_bar'                     => true,
		'wp_cockneyreplace'                => true,
		'wp_current_db_version'            => true,
		'wp_current_filter'                => true,
		'wp_customize'                     => true,
		'wp_dashboard_control_callbacks'   => true,
		'wp_db_version'                    => true,
		'wp_did_header'                    => true,
		'wp_embed'                         => true,
		'wp_file_descriptions'             => true,
		'wp_filesystem'                    => true,
		'wp_filter'                        => true,
		'wp_hasher'                        => true,
		'wp_header_to_desc'                => true,
		'wp_importers'                     => true,
		'wp_json'                          => true,
		'wp_list_table'                    => true,
		'wp_local_package'                 => true,
		'wp_locale'                        => true,
		'wp_meta_boxes'                    => true,
		'wp_object_cache'                  => true,
		'wp_plugin_paths'                  => true,
		'wp_post_statuses'                 => true,
		'wp_post_types'                    => true,
		'wp_queries'                       => true,
		'wp_query'                         => true,
		'wp_registered_sidebars'           => true,
		'wp_registered_widget_controls'    => true,
		'wp_registered_widget_updates'     => true,
		'wp_registered_widgets'            => true,
		'wp_rewrite'                       => true,
		'wp_rich_edit'                     => true,
		'wp_rich_edit_exists'              => true,
		'wp_roles'                         => true,
		'wp_scripts'                       => true,
		'wp_settings_errors'               => true,
		'wp_settings_fields'               => true,
		'wp_settings_sections'             => true,
		'wp_smiliessearch'                 => true,
		'wp_styles'                        => true,
		'wp_taxonomies'                    => true,
		'wp_the_query'                     => true,
		'wp_theme_directories'             => true,
		'wp_themes'                        => true,
		'wp_user_roles'                    => true,
		'wp_version'                       => true,
		'wp_widget_factory'                => true,
		'wp_xmlrpc_server'                 => true,
		'wpcommentsjavascript'             => true,
		'wpcommentspopupfile'              => true,
		'wpdb'                             => true,
		'wpsmiliestrans'                   => true,
		'year'                             => true,
	);

	/**
	 * A list of superglobals that incorporate user input.
	 *
	 * @since 0.5.0
	 * @since 0.11.0 Changed from static to non-static.
	 *
	 * @var string[]
	 */
	protected $input_superglobals = array(
		'$_COOKIE',
		'$_GET',
		'$_FILES',
		'$_POST',
		'$_REQUEST',
		'$_SERVER',
	);

	/**
	 * Whitelist of classes which test classes can extend.
	 *
	 * @since 0.11.0
	 *
	 * @var string[]
	 */
	protected $test_class_whitelist = array(
		'WP_UnitTestCase'            => true,
		'PHPUnit_Framework_TestCase' => true,
		'PHPUnit\Framework\TestCase' => true,
	);

	/**
	 * Custom list of classes which test classes can extend.
	 *
	 * This property allows end-users to add to the $test_class_whitelist via their ruleset.
	 * This property will need to be set for each sniff which uses the
	 * `is_test_class()` method.
	 * Currently the method is used by the `WordPress.Variables.GlobalVariables`,
	 * `WordPress.NamingConventions.PrefixAllGlobals` and the `WordPress.Files.Filename` sniffs.
	 *
	 * Example usage:
	 * <rule ref="WordPress.[Subset].[Sniffname]">
	 *  <properties>
	 *   <property name="custom_test_class_whitelist" type="array" value="My_Plugin_First_Test_Class,My_Plugin_Second_Test_Class"/>
	 *  </properties>
	 * </rule>
	 *
	 * @since 0.11.0
	 *
	 * @var string|string[]
	 */
	public $custom_test_class_whitelist = array();

	/**
	 * The current file being sniffed.
	 *
	 * @since 0.4.0
	 *
	 * @var PHP_CodeSniffer_File
	 */
	protected $phpcsFile;

	/**
	 * The list of tokens in the current file being sniffed.
	 *
	 * @since 0.4.0
	 *
	 * @var array
	 */
	protected $tokens;

	/**
	 * Set sniff properties and hand off to child class for processing of the token.
	 *
	 * @since 0.11.0
	 *
	 * @param PHP_CodeSniffer_File $phpcsFile The file being scanned.
	 * @param int                  $stackPtr  The position of the current token
	 *                                        in the stack passed in $tokens.
	 *
	 * @return int|void Integer stack pointer to skip forward or void to continue
	 *                  normal file processing.
	 */
	public function process( PHP_CodeSniffer_File $phpcsFile, $stackPtr ) {
		$this->init( $phpcsFile );
		return $this->process_token( $stackPtr );
	}

	/**
	 * Processes a sniff when one of its tokens is encountered.
	 *
	 * @since 0.11.0
	 *
	 * @param int $stackPtr The position of the current token in the stack.
	 *
	 * @return int|void Integer stack pointer to skip forward or void to continue
	 *                  normal file processing.
	 */
	abstract public function process_token( $stackPtr );

	/**
	 * Initialize the class for the current process.
	 *
	 * This method must be called by child classes before using many of the methods
	 * below.
	 *
	 * @since 0.4.0
	 *
	 * @param PHP_CodeSniffer_File $phpcsFile The file currently being processed.
	 */
	protected function init( PHP_CodeSniffer_File $phpcsFile ) {
		$this->phpcsFile = $phpcsFile;
		$this->tokens    = $phpcsFile->getTokens();
	}

	/**
	 * Strip quotes surrounding an arbitrary string.
	 *
	 * Intended for use with the content of a T_CONSTANT_ENCAPSED_STRING / T_DOUBLE_QUOTED_STRING.
	 *
	 * @since 0.11.0
	 *
	 * @param string $string The raw string.
	 * @return string String without quotes around it.
	 */
	public function strip_quotes( $string ) {
		return preg_replace( '`^([\'"])(.*)\1$`Ds', '$2', $string );
	}

	/**
	 * Add a PHPCS message to the output stack as either a warning or an error.
	 *
	 * @since 0.11.0
	 *
	 * @param string $message   The message.
	 * @param int    $stackPtr  The position of the token the message relates to.
	 * @param bool   $is_error  Optional. Whether to report the message as an 'error' or 'warning'.
	 *                          Defaults to true (error).
	 * @param string $code      Optional error code for the message. Defaults to 'Found'.
	 * @param array  $data      Optional input for the data replacements.
	 * @param int    $severity  Optional. Severity level. Defaults to 0 which will translate to
	 *                          the PHPCS default severity level.
	 * @return bool
	 */
	protected function addMessage( $message, $stackPtr, $is_error = true, $code = 'Found', $data = array(), $severity = 0 ) {
		return $this->throwMessage( $message, $stackPtr, $is_error, $code, $data, $severity, false );
	}

	/**
	 * Add a fixable PHPCS message to the output stack as either a warning or an error.
	 *
	 * @since 0.11.0
	 *
	 * @param string $message   The message.
	 * @param int    $stackPtr  The position of the token the message relates to.
	 * @param bool   $is_error  Optional. Whether to report the message as an 'error' or 'warning'.
	 *                          Defaults to true (error).
	 * @param string $code      Optional error code for the message. Defaults to 'Found'.
	 * @param array  $data      Optional input for the data replacements.
	 * @param int    $severity  Optional. Severity level. Defaults to 0 which will translate to
	 *                          the PHPCS default severity level.
	 * @return bool
	 */
	protected function addFixableMessage( $message, $stackPtr, $is_error = true, $code = 'Found', $data = array(), $severity = 0 ) {
		return $this->throwMessage( $message, $stackPtr, $is_error, $code, $data, $severity, true );
	}

	/**
	 * Add a PHPCS message to the output stack as either a warning or an error.
	 *
	 * @since 0.11.0
	 *
	 * @param string $message   The message.
	 * @param int    $stackPtr  The position of the token the message relates to.
	 * @param bool   $is_error  Optional. Whether to report the message as an 'error' or 'warning'.
	 *                          Defaults to true (error).
	 * @param string $code      Optional error code for the message. Defaults to 'Found'.
	 * @param array  $data      Optional input for the data replacements.
	 * @param int    $severity  Optional. Severity level. Defaults to 0 which will translate to
	 *                          the PHPCS default severity level.
	 * @param bool   $fixable   Optional. Whether this is a fixable error. Defaults to false.
	 * @return bool
	 */
	private function throwMessage( $message, $stackPtr, $is_error = true, $code = 'Found', $data = array(), $severity = 0, $fixable = false ) {

		$method = 'add';
		if ( true === $fixable ) {
			$method .= 'Fixable';
		}

		if ( true === $is_error ) {
			$method .= 'Error';
		} else {
			$method .= 'Warning';
		}

		return call_user_func( array( $this->phpcsFile, $method ), $message, $stackPtr, $code, $data, $severity );
	}

	/**
	 * Convert an arbitrary string to an alphanumeric string with underscores.
	 *
	 * Pre-empt issues with arbitrary strings being used as error codes in XML and PHP.
	 *
	 * @since 0.11.0
	 *
	 * @param string $base_string Arbitrary string.
	 *
	 * @return string
	 */
	protected function string_to_errorcode( $base_string ) {
		return preg_replace( '`[^a-z0-9_]`i', '_', $base_string );
	}

	/**
	 * Merge a pre-set array with a ruleset provided array or inline provided string.
	 *
	 * - Will correctly handle custom array properties which were set without
	 *   the `type="array"` indicator.
	 *   This also allows for making these custom array properties testable using
	 *   a `@codingStandardsChangeSetting` comment in the unit tests.
	 * - By default flips custom lists to allow for using `isset()` instead
	 *   of `in_array()`.
	 * - When `$flip` is true:
	 *   * Presumes the base array is in a `'value' => true` format.
	 *   * Any custom items will be given the value `false` to be able to
	 *     distinguish them from pre-set (base array) values.
	 *   * Will filter previously added custom items out from the base array
	 *     before merging/returning to allow for resetting to the base array.
	 *
	 * {@internal Function is static as it doesn't use any of the properties or others
	 * methods anyway and this way the `WordPress_Sniffs_NamingConventions_ValidVariableNameSniff`
	 * which extends an upstream sniff can also use it.}}
	 *
	 * @since 0.11.0
	 *
	 * @param array|string $custom Custom list as provided via a ruleset.
	 *                             Can be either a comma-delimited string or
	 *                             an array of values.
	 * @param array        $base   Optional. Base list. Defaults to an empty array.
	 *                             Expects `value => true` format when `$flip` is true.
	 * @param bool         $flip   Optional. Whether or not to flip the custom list.
	 *                             Defaults to true.
	 * @return array
	 */
	public static function merge_custom_array( $custom, $base = array(), $flip = true ) {
		if ( true === $flip ) {
			$base = array_filter( $base );
		}

		if ( empty( $custom ) || ( ! is_array( $custom ) && ! is_string( $custom ) ) ) {
			return $base;
		}

		// Allow for a comma delimited list.
		if ( is_string( $custom ) ) {
			$custom = array_filter( array_map( 'trim', explode( ',', $custom ) ) );
		}

		if ( true === $flip ) {
			$custom = array_fill_keys( $custom, false );
		}

		if ( empty( $base ) ) {
			return $custom;
		}

		return array_merge( $base, $custom );
	}

	/**
	 * Get the last pointer in a line.
	 *
	 * @since 0.4.0
	 *
	 * @param integer $stackPtr The position of the current token in the stack passed
	 *                          in $tokens.
	 *
	 * @return integer Position of the last pointer on that line.
	 */
	protected function get_last_ptr_on_line( $stackPtr ) {

		$tokens      = $this->tokens;
		$currentLine = $tokens[ $stackPtr ]['line'];
		$nextPtr     = ( $stackPtr + 1 );

		while ( isset( $tokens[ $nextPtr ] ) && $tokens[ $nextPtr ]['line'] === $currentLine ) {
			$nextPtr++;
			// Do nothing, we just want the last token of the line.
		}

		// We've made it to the next line, back up one to the last in the previous line.
		// We do this for micro-optimization of the above loop.
		$lastPtr = ( $nextPtr - 1 );

		return $lastPtr;
	}

	/**
	 * Find whitelisting comment.
	 *
	 * Comment must be at the end of the line, and use // format.
	 * It can be prefixed or suffixed with anything e.g. "foobar" will match:
	 * ... // foobar okay
	 * ... // WPCS: foobar whitelist.
	 *
	 * There is an exception, and that is when PHP is being interspersed with HTML.
	 * In that case, the comment should come at the end of the statement (right
	 * before the closing tag, ?>). For example:
	 *
	 * <input type="text" id="<?php echo $id; // XSS OK ?>" />
	 *
	 * @since 0.4.0
	 *
	 * @param string  $comment  Comment to find.
	 * @param integer $stackPtr The position of the current token in the stack passed
	 *                          in $tokens.
	 *
	 * @return boolean True if whitelisting comment was found, false otherwise.
	 */
	protected function has_whitelist_comment( $comment, $stackPtr ) {

		$lastPtr     = $this->get_last_ptr_on_line( $stackPtr );
		$end_of_line = $lastPtr;

		// There is a findEndOfStatement() method, but it considers more tokens than
		// we need to here.
		$end_of_statement = $this->phpcsFile->findNext( array( T_CLOSE_TAG, T_SEMICOLON ), $stackPtr );

		// Check at the end of the statement if it comes before - or is - the end of the line.
		if ( $end_of_statement <= $end_of_line ) {

			// If the statement was ended by a semicolon, we find the next non-
			// whitespace token. If the semicolon was left out and it was terminated
			// by an ending tag, we need to look backwards.
			if ( T_SEMICOLON === $this->tokens[ $end_of_statement ]['code'] ) {
				$lastPtr = $this->phpcsFile->findNext( T_WHITESPACE, ( $end_of_statement + 1 ), null, true );
			} else {
				$lastPtr = $this->phpcsFile->findPrevious( T_WHITESPACE, ( $end_of_statement - 1 ), null, true );
			}
		}

		$last = $this->tokens[ $lastPtr ];

		// Ignore if not a comment or not on the same line.
		if ( T_COMMENT !== $last['code'] || $last['line'] !== $this->tokens[ $end_of_line ]['line'] ) {
			return false;
		}

		// Now let's see if the comment contains the whitelist remark we're looking for.
		return ( preg_match( '#\b' . preg_quote( $comment, '#' ) . '\b#i', $last['content'] ) === 1 );
	}

	/**
	 * Check if a token is used within a unit test.
	 *
	 * Unit test methods are identified as such:
	 * - Method name starts with `test_`.
	 * - Method is within a unit test class.
	 *
	 * @since 0.11.0
	 *
	 * @param int $stackPtr The position of the token to be examined.
	 *
	 * @return bool True if the token is within a unit test, false otherwise.
	 */
	protected function is_token_in_test_method( $stackPtr ) {
		// Is the token inside of a function definition ?
		$functionToken = $this->phpcsFile->getCondition( $stackPtr, T_FUNCTION );
		if ( false === $functionToken ) {
			return false;
		}

		// Is this a method inside of a class or a trait ?
		$classToken = $this->phpcsFile->getCondition( $functionToken, T_CLASS );
		$traitToken = $this->phpcsFile->getCondition( $functionToken, T_TRAIT );
		if ( false === $classToken && false === $traitToken ) {
			return false;
		}

		$structureToken = $classToken;
		if ( false !== $traitToken ) {
			$structureToken = $traitToken;
		}

		return $this->is_test_class( $structureToken );
	}

	/**
	 * Check if a class token is part of a unit test suite.
	 *
	 * Unit test classes are identified as such:
	 * - Class which either extends WP_UnitTestCase or PHPUnit_Framework_TestCase
	 *   or a custom whitelisted unit test class.
	 *
	 * @since 0.12.0 Split off from the `is_token_in_test_method()` method.
	 *
	 * @param int $stackPtr The position of the token to be examined.
	 *                      This should be a class, anonymous class or trait token.
	 *
	 * @return bool True if the class is a unit test class, false otherwise.
	 */
	protected function is_test_class( $stackPtr ) {

		if ( ! isset( $this->tokens[ $stackPtr ] )
			|| in_array( $this->tokens[ $stackPtr ]['type'], array( 'T_CLASS', 'T_ANON_CLASS', 'T_TRAIT' ), true ) === false
		) {
			return false;
		}

		// Add any potentially whitelisted custom test classes to the whitelist.
		$whitelist = $this->merge_custom_array(
			$this->custom_test_class_whitelist,
			$this->test_class_whitelist
		);

		// Is the class/trait one of the whitelisted test classes ?
		$className = $this->phpcsFile->getDeclarationName( $stackPtr );
		if ( isset( $whitelist[ $className ] ) ) {
			return true;
		}

		// Does the class/trait extend one of the whitelisted test classes ?
		$extendedClassName = $this->phpcsFile->findExtendedClassName( $stackPtr );
		if ( isset( $whitelist[ $extendedClassName ] ) ) {
			return true;
		}

		return false;
	}

	/**
	 * Check if this variable is being assigned a value.
	 *
	 * E.g., $var = 'foo';
	 *
	 * Also handles array assignments to arbitrary depth:
	 *
	 * $array['key'][ $foo ][ something() ] = $bar;
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The index of the token in the stack. This must point to
	 *                      either a T_VARIABLE or T_CLOSE_SQUARE_BRACKET token.
	 *
	 * @return bool Whether the token is a variable being assigned a value.
	 */
	protected function is_assignment( $stackPtr ) {

		static $valid = array(
			T_VARIABLE             => true,
			T_CLOSE_SQUARE_BRACKET => true,
		);

		// Must be a variable, constant or closing square bracket (see below).
		if ( ! isset( $valid[ $this->tokens[ $stackPtr ]['code'] ] ) ) {
			return false;
		}

		$next_non_empty = $this->phpcsFile->findNext(
			PHP_CodeSniffer_Tokens::$emptyTokens
			, ( $stackPtr + 1 )
			, null
			, true
			, null
			, true
		);

		// No token found.
		if ( false === $next_non_empty ) {
			return false;
		}

		// If the next token is an assignment, that's all we need to know.
		if ( isset( PHP_CodeSniffer_Tokens::$assignmentTokens[ $this->tokens[ $next_non_empty ]['code'] ] ) ) {
			return true;
		}

		// Check if this is an array assignment, e.g., `$var['key'] = 'val';` .
		if ( T_OPEN_SQUARE_BRACKET === $this->tokens[ $next_non_empty ]['code'] ) {
			return $this->is_assignment( $this->tokens[ $next_non_empty ]['bracket_closer'] );
		}

		return false;
	}

	/**
	 * Check if this token has an associated nonce check.
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The position of the current token in the stack of tokens.
	 *
	 * @return bool
	 */
	protected function has_nonce_check( $stackPtr ) {

		/**
		 * A cache of the scope that we last checked for nonce verification in.
		 *
		 * @var array {
		 *      @var string   $file        The name of the file.
		 *      @var int      $start       The index of the token where the scope started.
		 *      @var int      $end         The index of the token where the scope ended.
		 *      @var bool|int $nonce_check The index of the token where an nonce check
		 *                                 was found, or false if none was found.
		 * }
		 */
		static $last;

		$start = 0;
		$end   = $stackPtr;

		$tokens = $this->phpcsFile->getTokens();

		// If we're in a function, only look inside of it.
		$f = $this->phpcsFile->getCondition( $stackPtr, T_FUNCTION );
		if ( false !== $f ) {
			$start = $tokens[ $f ]['scope_opener'];
		} else {
			$f = $this->phpcsFile->getCondition( $stackPtr, T_CLOSURE );
			if ( false !== $f ) {
				$start = $tokens[ $f ]['scope_opener'];
			}
		}

		$in_isset = $this->is_in_isset_or_empty( $stackPtr );

		// We allow for isset( $_POST['var'] ) checks to come before the nonce check.
		// If this is inside an isset(), check after it as well, all the way to the
		// end of the scope.
		if ( $in_isset ) {
			$end = ( 0 === $start ) ? $this->phpcsFile->numTokens : $tokens[ $start ]['scope_closer'];
		}

		// Check if we've looked here before.
		$filename = $this->phpcsFile->getFilename();

		if (
			$filename === $last['file']
			&& $start === $last['start']
		) {

			if ( false !== $last['nonce_check'] ) {
				// If we have already found an nonce check in this scope, we just
				// need to check whether it comes before this token. It is OK if the
				// check is after the token though, if this was only a isset() check.
				return ( $in_isset || $last['nonce_check'] < $stackPtr );
			} elseif ( $end <= $last['end'] ) {
				// If not, we can still go ahead and return false if we've already
				// checked to the end of the search area.
				return false;
			}

			// We haven't checked this far yet, but we can still save work by
			// skipping over the part we've already checked.
			$start = $last['end'];
		} else {
			$last = array(
				'file'  => $filename,
				'start' => $start,
				'end'   => $end,
			);
		}

		// Loop through the tokens looking for nonce verification functions.
		for ( $i = $start; $i < $end; $i++ ) {

			// If this isn't a function name, skip it.
			if ( T_STRING !== $tokens[ $i ]['code'] ) {
				continue;
			}

			// If this is one of the nonce verification functions, we can bail out.
			if ( isset( $this->nonceVerificationFunctions[ $tokens[ $i ]['content'] ] ) ) {
				$last['nonce_check'] = $i;
				return true;
			}
		}

		// We're still here, so no luck.
		$last['nonce_check'] = false;

		return false;
	}

	/**
	 * Check if a token is inside of an isset() or empty() statement.
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The index of the token in the stack.
	 *
	 * @return bool Whether the token is inside an isset() or empty() statement.
	 */
	protected function is_in_isset_or_empty( $stackPtr ) {

		if ( ! isset( $this->tokens[ $stackPtr ]['nested_parenthesis'] ) ) {
			return false;
		}

		end( $this->tokens[ $stackPtr ]['nested_parenthesis'] );
		$open_parenthesis = key( $this->tokens[ $stackPtr ]['nested_parenthesis'] );
		reset( $this->tokens[ $stackPtr ]['nested_parenthesis'] );

		return in_array( $this->tokens[ ( $open_parenthesis - 1 ) ]['code'], array( T_ISSET, T_EMPTY ), true );
	}

	/**
	 * Check if something is only being sanitized.
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The index of the token in the stack.
	 *
	 * @return bool Whether the token is only within a sanitization.
	 */
	protected function is_only_sanitized( $stackPtr ) {

		// If it isn't being sanitized at all.
		if ( ! $this->is_sanitized( $stackPtr ) ) {
			return false;
		}

		// If this isn't set, we know the value must have only been casted, because
		// is_sanitized() would have returned false otherwise.
		if ( ! isset( $this->tokens[ $stackPtr ]['nested_parenthesis'] ) ) {
			return true;
		}

		// At this point we're expecting the value to have not been casted. If it
		// was, it wasn't *only* casted, because it's also in a function.
		if ( $this->is_safe_casted( $stackPtr ) ) {
			return false;
		}

		// The only parentheses should belong to the sanitizing function. If there's
		// more than one set, this isn't *only* sanitization.
		return ( count( $this->tokens[ $stackPtr ]['nested_parenthesis'] ) === 1 );
	}

	/**
	 * Check if something is being casted to a safe value.
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The index of the token in the stack.
	 *
	 * @return bool Whether the token being casted.
	 */
	protected function is_safe_casted( $stackPtr ) {

		// Get the last non-empty token.
		$prev = $this->phpcsFile->findPrevious(
			PHP_CodeSniffer_Tokens::$emptyTokens
			, ( $stackPtr - 1 )
			, null
			, true
		);

		// Check if it is a safe cast.
		return in_array( $this->tokens[ $prev ]['code'], array( T_INT_CAST, T_DOUBLE_CAST, T_BOOL_CAST ), true );
	}

	/**
	 * Check if something is being sanitized.
	 *
	 * @since 0.5.0
	 *
	 * @param int  $stackPtr        The index of the token in the stack.
	 * @param bool $require_unslash Whether to give an error if wp_unslash() isn't
	 *                              used on the variable before sanitization.
	 *
	 * @return bool Whether the token being sanitized.
	 */
	protected function is_sanitized( $stackPtr, $require_unslash = false ) {

		// First we check if it is being casted to a safe value.
		if ( $this->is_safe_casted( $stackPtr ) ) {
			return true;
		}

		// If this isn't within a function call, we know already that it's not safe.
		if ( ! isset( $this->tokens[ $stackPtr ]['nested_parenthesis'] ) ) {
			if ( $require_unslash ) {
				$this->add_unslash_error( $stackPtr );
			}
			return false;
		}

		// Get the function that it's in.
		$function_closer = end( $this->tokens[ $stackPtr ]['nested_parenthesis'] );
		$function_opener = key( $this->tokens[ $stackPtr ]['nested_parenthesis'] );
		$function        = $this->tokens[ ( $function_opener - 1 ) ];

		// If it is just being unset, the value isn't used at all, so it's safe.
		if ( T_UNSET === $function['code'] ) {
			return true;
		}

		// If this isn't a call to a function, it sure isn't sanitizing function.
		if ( T_STRING !== $function['code'] ) {
			if ( $require_unslash ) {
				$this->add_unslash_error( $stackPtr );
			}
			return false;
		}

		$functionName = $function['content'];

		// Check if wp_unslash() is being used.
		if ( 'wp_unslash' === $functionName ) {

			$is_unslashed    = true;
			$function_closer = prev( $this->tokens[ $stackPtr ]['nested_parenthesis'] );

			// If there is no other function being used, this value is unsanitized.
			if ( ! $function_closer ) {
				return false;
			}

			$function_opener = key( $this->tokens[ $stackPtr ]['nested_parenthesis'] );
			$functionName    = $this->tokens[ ( $function_opener - 1 ) ]['content'];

		} else {

			$is_unslashed = false;
		}

		// Arrays might be sanitized via array_map().
		if ( 'array_map' === $functionName ) {

			// Get the first parameter.
			$callback = $this->get_function_call_parameter( ( $function_opener - 1 ), 1 );

			if ( ! empty( $callback ) ) {
				/*
				 * If this is a function callback (not a method callback array) and we're able
				 * to resolve the function name, do so.
				 */
				$first_non_empty = $this->phpcsFile->findNext(
					PHP_CodeSniffer_Tokens::$emptyTokens,
					$callback['start'],
					( $callback['end'] + 1 ),
					true
				);

				if ( false !== $first_non_empty && T_CONSTANT_ENCAPSED_STRING === $this->tokens[ $first_non_empty ]['code'] ) {
					$functionName = $this->strip_quotes( $this->tokens[ $first_non_empty ]['content'] );
				}
			}
		}

		// If slashing is required, give an error.
		if ( ! $is_unslashed && $require_unslash && ! isset( $this->unslashingSanitizingFunctions[ $functionName ] ) ) {
			$this->add_unslash_error( $stackPtr );
		}

		// Check if this is a sanitizing function.
		if ( isset( $this->sanitizingFunctions[ $functionName ] ) || isset( $this->unslashingSanitizingFunctions[ $functionName ] ) ) {
			return true;
		}

		return false;
	}

	/**
	 * Add an error for missing use of wp_unslash().
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The index of the token in the stack.
	 */
	public function add_unslash_error( $stackPtr ) {

		$this->phpcsFile->addError(
			'Missing wp_unslash() before sanitization.',
			$stackPtr,
			'MissingUnslash',
			array( $this->tokens[ $stackPtr ]['content'] )
		);
	}

	/**
	 * Get the index key of an array variable.
	 *
	 * E.g., "bar" in $foo['bar'].
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The index of the token in the stack.
	 *
	 * @return string|false The array index key whose value is being accessed.
	 */
	protected function get_array_access_key( $stackPtr ) {

		// Find the next non-empty token.
		$open_bracket = $this->phpcsFile->findNext(
			PHP_CodeSniffer_Tokens::$emptyTokens,
			( $stackPtr + 1 ),
			null,
			true
		);

		// If it isn't a bracket, this isn't an array-access.
		if ( false === $open_bracket || T_OPEN_SQUARE_BRACKET !== $this->tokens[ $open_bracket ]['code'] ) {
			return false;
		}

		$key = $this->phpcsFile->getTokensAsString(
			( $open_bracket + 1 )
			, ( $this->tokens[ $open_bracket ]['bracket_closer'] - $open_bracket - 1 )
		);

		return trim( $key );
	}

	/**
	 * Check if the existence of a variable is validated with isset() or empty().
	 *
	 * When $in_condition_only is false, (which is the default), this is considered
	 * valid:
	 *
	 * ```php
	 * if ( isset( $var ) ) {
	 *     // Do stuff, like maybe return or exit (but could be anything)
	 * }
	 *
	 * foo( $var );
	 * ```
	 *
	 * When it is true, that would be invalid, the use of the variable must be within
	 * the scope of the validating condition, like this:
	 *
	 * ```php
	 * if ( isset( $var ) ) {
	 *     foo( $var );
	 * }
	 * ```
	 *
	 * @since 0.5.0
	 *
	 * @param int    $stackPtr          The index of this token in the stack.
	 * @param string $array_key         An array key to check for ("bar" in $foo['bar']).
	 * @param bool   $in_condition_only Whether to require that this use of the
	 *                                  variable occur within the scope of the
	 *                                  validating condition, or just in the same
	 *                                  scope as it (default).
	 *
	 * @return bool Whether the var is validated.
	 */
	protected function is_validated( $stackPtr, $array_key = null, $in_condition_only = false ) {

		if ( $in_condition_only ) {
			/*
			   This is a stricter check, requiring the variable to be used only
			   within the validation condition.
			 */

			// If there are no conditions, there's no validation.
			if ( empty( $this->tokens[ $stackPtr ]['conditions'] ) ) {
				return false;
			}

			$conditions = $this->tokens[ $stackPtr ]['conditions'];
			end( $conditions ); // Get closest condition.
			$conditionPtr = key( $conditions );
			$condition    = $this->tokens[ $conditionPtr ];

			if ( ! isset( $condition['parenthesis_opener'] ) ) {
				// Live coding or parse error.
				return false;
			}

			$scope_start = $condition['parenthesis_opener'];
			$scope_end   = $condition['parenthesis_closer'];

		} else {
			/*
			   We are are more loose, requiring only that the variable be validated
			   in the same function/file scope as it is used.
			 */

			$scope_start = 0;

			// Check if we are in a function.
			$function = $this->phpcsFile->getCondition( $stackPtr, T_FUNCTION );

			// If so, we check only within the function, otherwise the whole file.
			if ( false !== $function ) {
				$scope_start = $this->tokens[ $function ]['scope_opener'];
			} else {
				// Check if we are in a closure.
				$closure = $this->phpcsFile->getCondition( $stackPtr, T_CLOSURE );

				// If so, we check only within the closure.
				if ( false !== $closure ) {
					$scope_start = $this->tokens[ $closure ]['scope_opener'];
				}
			}

			$scope_end = $stackPtr;

		}

		for ( $i = ( $scope_start + 1 ); $i < $scope_end; $i++ ) {

			if ( ! in_array( $this->tokens[ $i ]['code'], array( T_ISSET, T_EMPTY, T_UNSET ), true ) ) {
				continue;
			}

			$issetOpener = $this->phpcsFile->findNext( T_OPEN_PARENTHESIS, $i );
			$issetCloser = $this->tokens[ $issetOpener ]['parenthesis_closer'];

			// Look for this variable. We purposely stomp $i from the parent loop.
			for ( $i = ( $issetOpener + 1 ); $i < $issetCloser; $i++ ) {

				if ( T_VARIABLE !== $this->tokens[ $i ]['code'] ) {
					continue;
				}

				// If we're checking for a specific array key (ex: 'hello' in
				// $_POST['hello']), that must match too.
				if ( isset( $array_key ) && $this->get_array_access_key( $i ) !== $array_key ) {
					continue;
				}

				return true;
			}
		}

		return false;
	}

	/**
	 * Check whether a variable is being compared to another value.
	 *
	 * E.g., $var === 'foo', 1 <= $var, etc.
	 *
	 * Also recognizes `switch ( $var )`.
	 *
	 * @since 0.5.0
	 *
	 * @param int $stackPtr The index of this token in the stack.
	 *
	 * @return bool Whether this is a comparison.
	 */
	protected function is_comparison( $stackPtr ) {

		// We first check if this is a switch statement (switch ( $var )).
		if ( isset( $this->tokens[ $stackPtr ]['nested_parenthesis'] ) ) {
			$close_parenthesis = end( $this->tokens[ $stackPtr ]['nested_parenthesis'] );

			if (
				isset( $this->tokens[ $close_parenthesis ]['parenthesis_owner'] )
				&& T_SWITCH === $this->tokens[ $this->tokens[ $close_parenthesis ]['parenthesis_owner'] ]['code']
			) {
				return true;
			}
		}

		// Find the previous non-empty token. We check before the var first because
		// yoda conditions are usually expected.
		$previous_token = $this->phpcsFile->findPrevious(
			PHP_CodeSniffer_Tokens::$emptyTokens,
			( $stackPtr - 1 ),
			null,
			true
		);

		if ( isset( PHP_CodeSniffer_Tokens::$comparisonTokens[ $this->tokens[ $previous_token ]['code'] ] ) ) {
			return true;
		}

		// Maybe the comparison operator is after this.
		$next_token = $this->phpcsFile->findNext(
			PHP_CodeSniffer_Tokens::$emptyTokens,
			( $stackPtr + 1 ),
			null,
			true
		);

		// This might be an opening square bracket in the case of arrays ($var['a']).
		while ( T_OPEN_SQUARE_BRACKET === $this->tokens[ $next_token ]['code'] ) {

			$next_token = $this->phpcsFile->findNext(
				PHP_CodeSniffer_Tokens::$emptyTokens,
				( $this->tokens[ $next_token ]['bracket_closer'] + 1 ),
				null,
				true
			);
		}

		if ( isset( PHP_CodeSniffer_Tokens::$comparisonTokens[ $this->tokens[ $next_token ]['code'] ] ) ) {
			return true;
		}

		return false;
	}

	/**
	 * Check what type of 'use' statement a token is part of.
	 *
	 * The T_USE token has multiple different uses:
	 *
	 * 1. In a closure: function () use ( $var ) {}
	 * 2. In a class, to import a trait: use Trait_Name
	 * 3. In a namespace, to import a class: use Some\Class;
	 *
	 * This function will check the token and return 'closure', 'trait', or 'class',
	 * based on which of these uses the use is being used for.
	 *
	 * @since 0.7.0
	 *
	 * @param int $stackPtr The position of the token to check.
	 *
	 * @return string The type of use.
	 */
	protected function get_use_type( $stackPtr ) {

		// USE keywords inside closures.
		$next = $this->phpcsFile->findNext( T_WHITESPACE, ( $stackPtr + 1 ), null, true );

		if ( T_OPEN_PARENTHESIS === $this->tokens[ $next ]['code'] ) {
			return 'closure';
		}

		// USE keywords for traits.
		if ( $this->phpcsFile->hasCondition( $stackPtr, array( T_CLASS, T_ANON_CLASS, T_TRAIT ) ) ) {
			return 'trait';
		}

		// USE keywords for classes to import to a namespace.
		return 'class';
	}

	/**
	 * Get the interpolated variable names from a string.
	 *
	 * Check if '$' is followed by a valid variable name, and that it is not preceded by an escape sequence.
	 *
	 * @since 0.9.0
	 *
	 * @param string $string A T_DOUBLE_QUOTED_STRING or T_HEREDOC token.
	 *
	 * @return array Variable names (without '$' sigil).
	 */
	protected function get_interpolated_variables( $string ) {
		$variables = array();
		if ( preg_match_all( '/(?P<backslashes>\\\\*)\$(?P<symbol>\w+)/', $string, $match_sets, PREG_SET_ORDER ) ) {
			foreach ( $match_sets as $matches ) {
				if ( ! isset( $matches['backslashes'] ) || ( strlen( $matches['backslashes'] ) % 2 ) === 0 ) {
					$variables[] = $matches['symbol'];
				}
			}
		}
		return $variables;
	}

	/**
	 * Checks if a function call has parameters.
	 *
	 * Expects to be passed the T_STRING stack pointer for the function call.
	 * If passed a T_STRING which is *not* a function call, the behaviour is unreliable.
	 *
	 * Extra feature: If passed an T_ARRAY or T_OPEN_SHORT_ARRAY stack pointer, it
	 * will detect whether the array has values or is empty.
	 *
	 * @link https://github.com/wimg/PHPCompatibility/issues/120
	 * @link https://github.com/wimg/PHPCompatibility/issues/152
	 *
	 * @since 0.11.0
	 *
	 * @param int $stackPtr The position of the function call token.
	 *
	 * @return bool
	 */
	public function does_function_call_have_parameters( $stackPtr ) {

		// Check for the existence of the token.
		if ( false === isset( $this->tokens[ $stackPtr ] ) ) {
			return false;
		}

		// Is this one of the tokens this function handles ?
		if ( false === in_array( $this->tokens[ $stackPtr ]['code'], array( T_STRING, T_ARRAY, T_OPEN_SHORT_ARRAY ), true ) ) {
			return false;
		}

		$next_non_empty = $this->phpcsFile->findNext( PHP_CodeSniffer_Tokens::$emptyTokens, ( $stackPtr + 1 ), null, true, null, true );

		// Deal with short array syntax.
		if ( 'T_OPEN_SHORT_ARRAY' === $this->tokens[ $stackPtr ]['type'] ) {
			if ( false === isset( $this->tokens[ $stackPtr ]['bracket_closer'] ) ) {
				return false;
			}

			if ( $next_non_empty === $this->tokens[ $stackPtr ]['bracket_closer'] ) {
				// No parameters.
				return false;
			} else {
				return true;
			}
		}

		// Deal with function calls & long arrays.
		// Next non-empty token should be the open parenthesis.
		if ( false === $next_non_empty && T_OPEN_PARENTHESIS !== $this->tokens[ $next_non_empty ]['code'] ) {
			return false;
		}

		if ( false === isset( $this->tokens[ $next_non_empty ]['parenthesis_closer'] ) ) {
			return false;
		}

		$close_parenthesis   = $this->tokens[ $next_non_empty ]['parenthesis_closer'];
		$next_next_non_empty = $this->phpcsFile->findNext( PHP_CodeSniffer_Tokens::$emptyTokens, ( $next_non_empty + 1 ), ( $close_parenthesis + 1 ), true );

		if ( $next_next_non_empty === $close_parenthesis ) {
			// No parameters.
			return false;
		}

		return true;
	}

	/**
	 * Count the number of parameters a function call has been passed.
	 *
	 * Expects to be passed the T_STRING stack pointer for the function call.
	 * If passed a T_STRING which is *not* a function call, the behaviour is unreliable.
	 *
	 * Extra feature: If passed an T_ARRAY or T_OPEN_SHORT_ARRAY stack pointer,
	 * it will return the number of values in the array.
	 *
	 * @link https://github.com/wimg/PHPCompatibility/issues/111
	 * @link https://github.com/wimg/PHPCompatibility/issues/114
	 * @link https://github.com/wimg/PHPCompatibility/issues/151
	 *
	 * @since 0.11.0
	 *
	 * @param int $stackPtr The position of the function call token.
	 *
	 * @return int
	 */
	public function get_function_call_parameter_count( $stackPtr ) {
		if ( false === $this->does_function_call_have_parameters( $stackPtr ) ) {
			return 0;
		}

		return count( $this->get_function_call_parameters( $stackPtr ) );
	}

	/**
	 * Get information on all parameters passed to a function call.
	 *
	 * Expects to be passed the T_STRING stack pointer for the function call.
	 * If passed a T_STRING which is *not* a function call, the behaviour is unreliable.
	 *
	 * Extra feature: If passed an T_ARRAY or T_OPEN_SHORT_ARRAY stack pointer,
	 * it will tokenize the values / key/value pairs contained in the array call.
	 *
	 * @since 0.11.0
	 *
	 * @param int $stackPtr The position of the function call token.
	 *
	 * @return array Multi-dimentional array with parameter details or
	 *               empty array if no parameter are found.
	 *
	 *               @type int $position 1-based index position of the parameter. {
	 *                   @type int $start Stack pointer for the start of the parameter.
	 *                   @type int $end   Stack pointer for the end of parameter.
	 *                   @type int $raw   Trimmed raw parameter content.
	 *               }
	 */
	public function get_function_call_parameters( $stackPtr ) {
		if ( false === $this->does_function_call_have_parameters( $stackPtr ) ) {
			return array();
		}

		/*
		 * Ok, we know we have a T_STRING, T_ARRAY or T_OPEN_SHORT_ARRAY with parameters
		 * and valid open & close brackets/parenthesis.
		 */

		// Mark the beginning and end tokens.
		if ( 'T_OPEN_SHORT_ARRAY' === $this->tokens[ $stackPtr ]['type'] ) {
			$opener = $stackPtr;
			$closer = $this->tokens[ $stackPtr ]['bracket_closer'];

			$nestedParenthesisCount = 0;
		} else {
			$opener = $this->phpcsFile->findNext( PHP_CodeSniffer_Tokens::$emptyTokens, ( $stackPtr + 1 ), null, true, null, true );
			$closer = $this->tokens[ $opener ]['parenthesis_closer'];

			$nestedParenthesisCount = 1;
		}

		// Which nesting level is the one we are interested in ?
		if ( isset( $this->tokens[ $opener ]['nested_parenthesis'] ) ) {
			$nestedParenthesisCount += count( $this->tokens[ $opener ]['nested_parenthesis'] );
		}

		$parameters  = array();
		$next_comma  = $opener;
		$param_start = ( $opener + 1 );
		$cnt         = 1;
		while ( $next_comma = $this->phpcsFile->findNext( array( T_COMMA, $this->tokens[ $closer ]['code'], T_OPEN_SHORT_ARRAY ), ( $next_comma + 1 ), ( $closer + 1 ) ) ) {
			// Ignore anything within short array definition brackets.
			if ( 'T_OPEN_SHORT_ARRAY' === $this->tokens[ $next_comma ]['type']
				&& ( isset( $this->tokens[ $next_comma ]['bracket_opener'] )
					&& $this->tokens[ $next_comma ]['bracket_opener'] === $next_comma )
				&& isset( $this->tokens[ $next_comma ]['bracket_closer'] )
			) {
				// Skip forward to the end of the short array definition.
				$next_comma = $this->tokens[ $next_comma ]['bracket_closer'];
				continue;
			}

			// Ignore comma's at a lower nesting level.
			if ( T_COMMA === $this->tokens[ $next_comma ]['code']
				&& isset( $this->tokens[ $next_comma ]['nested_parenthesis'] )
				&& count( $this->tokens[ $next_comma ]['nested_parenthesis'] ) !== $nestedParenthesisCount
			) {
				continue;
			}

			// Ignore closing parenthesis/bracket if not 'ours'.
			if ( $this->tokens[ $next_comma ]['type'] === $this->tokens[ $closer ]['type'] && $next_comma !== $closer ) {
				continue;
			}

			// Ok, we've reached the end of the parameter.
			$parameters[ $cnt ]['start'] = $param_start;
			$parameters[ $cnt ]['end']   = ( $next_comma - 1 );
			$parameters[ $cnt ]['raw']   = trim( $this->phpcsFile->getTokensAsString( $param_start, ( $next_comma - $param_start ) ) );

			/*
			 * Check if there are more tokens before the closing parenthesis.
			 * Prevents code like the following from setting a third parameter:
			 * functionCall( $param1, $param2, );
			 */
			$has_next_param = $this->phpcsFile->findNext( PHP_CodeSniffer_Tokens::$emptyTokens, ( $next_comma + 1 ), $closer, true, null, true );
			if ( false === $has_next_param ) {
				break;
			}

			// Prepare for the next parameter.
			$param_start = ( $next_comma + 1 );
			$cnt++;
		}

		return $parameters;
	}

	/**
	 * Get information on a specific parameter passed to a function call.
	 *
	 * Expects to be passed the T_STRING stack pointer for the function call.
	 * If passed a T_STRING which is *not* a function call, the behaviour is unreliable.
	 *
	 * Will return a array with the start token pointer, end token pointer and the raw value
	 * of the parameter at a specific offset.
	 * If the specified parameter is not found, will return false.
	 *
	 * @since 0.11.0
	 *
	 * @param int $stackPtr     The position of the function call token.
	 * @param int $param_offset The 1-based index position of the parameter to retrieve.
	 *
	 * @return array|false
	 */
	public function get_function_call_parameter( $stackPtr, $param_offset ) {
		$parameters = $this->get_function_call_parameters( $stackPtr );

		if ( false === isset( $parameters[ $param_offset ] ) ) {
			return false;
		}

		return $parameters[ $param_offset ];
	}

	/**
	 * Find the array opener & closer based on a T_ARRAY or T_OPEN_SHORT_ARRAY token.
	 *
	 * @param int $stackPtr The stack pointer to the array token.
	 *
	 * @return array|bool Array with two keys `opener`, `closer` or false if
	 *                    either or these could not be determined.
	 */
	protected function find_array_open_close( $stackPtr ) {
		/*
		 * Determine the array opener & closer.
		 */
		if ( T_ARRAY === $this->tokens[ $stackPtr ]['code'] ) {
			if ( isset( $this->tokens[ $stackPtr ]['parenthesis_opener'] ) ) {
				$opener = $this->tokens[ $stackPtr ]['parenthesis_opener'];

				if ( isset( $this->tokens[ $opener ]['parenthesis_closer'] ) ) {
					$closer = $this->tokens[ $opener ]['parenthesis_closer'];
				}
			}
		} else {
			// Short array syntax.
			$opener = $stackPtr;

			if ( isset( $this->tokens[ $stackPtr ]['bracket_closer'] ) ) {
				$closer = $this->tokens[ $stackPtr ]['bracket_closer'];
			}
		}

		if ( isset( $opener, $closer ) ) {
			return array(
				'opener' => $opener,
				'closer' => $closer,
			);
		}

		return false;
	}

	/**
	 * Determine the namespace name an arbitrary token lives in.
	 *
	 * @since 0.10.0
	 * @since 0.12.0 Moved from the WordPress_AbstractClassRestrictionsSniff to this sniff.
	 *
	 * @param int $stackPtr The token position for which to determine the namespace.
	 *
	 * @return string Namespace name or empty string if it couldn't be determined or no namespace applies.
	 */
	public function determine_namespace( $stackPtr ) {

		// Check for the existence of the token.
		if ( ! isset( $this->tokens[ $stackPtr ] ) ) {
			return '';
		}

		// Check for scoped namespace {}.
		if ( ! empty( $this->tokens[ $stackPtr ]['conditions'] ) ) {
			$namespacePtr = $this->phpcsFile->getCondition( $stackPtr, T_NAMESPACE );
			if ( false !== $namespacePtr ) {
				$namespace = $this->get_declared_namespace_name( $namespacePtr );
				if ( false !== $namespace ) {
					return $namespace;
				}

				// We are in a scoped namespace, but couldn't determine the name.
				// Searching for a global namespace is futile.
				return '';
			}
		}

		/*
		 * Not in a scoped namespace, so let's see if we can find a non-scoped namespace instead.
		 * Keeping in mind that:
		 * - there can be multiple non-scoped namespaces in a file (bad practice, but it happens).
		 * - the namespace keyword can also be used as part of a function/method call and such.
		 * - that a non-named namespace resolves to the global namespace.
		 */
		$previousNSToken = $stackPtr;
		$namespace       = false;
		do {
			$previousNSToken = $this->phpcsFile->findPrevious( T_NAMESPACE, ( $previousNSToken - 1 ) );

			// Stop if we encounter a scoped namespace declaration as we already know we're not in one.
			if ( ! empty( $this->tokens[ $previousNSToken ]['scope_condition'] )
				&& $this->tokens[ $previousNSToken ]['scope_condition'] === $previousNSToken
			) {
				break;
			}

			$namespace = $this->get_declared_namespace_name( $previousNSToken );

		} while ( false === $namespace && false !== $previousNSToken );

		// If we still haven't got a namespace, return an empty string.
		if ( false === $namespace ) {
			return '';
		}

		return $namespace;
	}

	/**
	 * Get the complete namespace name for a namespace declaration.
	 *
	 * For hierarchical namespaces, the name will be composed of several tokens,
	 * i.e. MyProject\Sub\Level which will be returned together as one string.
	 *
	 * @since 0.12.0 A lesser variant of this method previously existed in the
	 *               WordPress_AbstractClassRestrictionsSniff.
	 *
	 * @param int|bool $stackPtr The position of a T_NAMESPACE token.
	 *
	 * @return string|false Namespace name or false if not a namespace declaration.
	 *                      Namespace name can be an empty string for global namespace declaration.
	 */
	public function get_declared_namespace_name( $stackPtr ) {

		// Check for the existence of the token.
		if ( false === $stackPtr || ! isset( $this->tokens[ $stackPtr ] ) ) {
			return false;
		}

		if ( T_NAMESPACE !== $this->tokens[ $stackPtr ]['code'] ) {
			return false;
		}

		if ( T_NS_SEPARATOR === $this->tokens[ ( $stackPtr + 1 ) ]['code'] ) {
			// Not a namespace declaration, but use of, i.e. `namespace\someFunction();`.
			return false;
		}

		$nextToken = $this->phpcsFile->findNext( PHP_CodeSniffer_Tokens::$emptyTokens, ( $stackPtr + 1 ), null, true, null, true );
		if ( T_OPEN_CURLY_BRACKET === $this->tokens[ $nextToken ]['code'] ) {
			// Declaration for global namespace when using multiple namespaces in a file.
			// I.e.: `namespace {}`.
			return '';
		}

		// Ok, this should be a namespace declaration, so get all the parts together.
		$validTokens = array(
			T_STRING       => true,
			T_NS_SEPARATOR => true,
			T_WHITESPACE   => true,
		);

		$namespaceName = '';
		while ( isset( $validTokens[ $this->tokens[ $nextToken ]['code'] ] ) ) {
			$namespaceName .= trim( $this->tokens[ $nextToken ]['content'] );
			$nextToken++;
		}

		return $namespaceName;
	}

	/**
	 * Check if a content string contains a specific html open tag.
	 *
	 * {@internal For PHP 5.3+ this is straightforward, just check if $content
	 * contains the tag.
	 * PHP 5.2 however, creates a separate token for `<s` when used in inline HTML,
	 * so in that case we need to check that the next token starts with the rest
	 * of the tag.
	 * I.e. PHP 5.2 tokenizes the inline HTML `text <span>text</span> text` as:
	 * - T_INLINE_HTML 'text'
	 * - T_INLINE_HTML '<s'
	 * - T_INLINE_HTML 'pan>text</span> text'
	 *
	 * We don't need to worry about checking the rest of the content of the next
	 * token as sniffs using this function will be sniffing for all text string
	 * tokens, so the next token will be passed to the sniff in the next iteration
	 * and checked then.
	 * Similarly, no need to check content before the '<s' as the bug will break up the
	 * inline html to several string tokens if it plays up.}}
	 *
	 * @link  https://bugs.php.net/bug.php?id=48446
	 *
	 * @since 0.11.0
	 *
	 * @param string $tag_name The name of the HTML tag without brackets. So if
	 *                         searching for '<span...', this would be 'span'.
	 * @param int    $stackPtr The position of the current token in the token stack.
	 * @param string $content  Optionally, the current content string, might be a
	 *                         substring of the original string.
	 *                         Defaults to `false` to distinguish between a passed
	 *                         empty string and not passing the $content string.
	 *
	 * @return bool True if the string contains an <tag_name> open tag, false otherwise.
	 */
	public function has_html_open_tag( $tag_name, $stackPtr, $content = false ) {
		if ( false === $content ) {
			$content = $this->tokens[ $stackPtr ]['content'];
		}

		// Check for the open tag in normal string tokens and T_INLINE_HTML for PHP 5.3+.
		if ( 's' !== $tag_name[0] || PHP_VERSION_ID >= 50300 || T_INLINE_HTML !== $this->tokens[ $stackPtr ]['code'] ) {
			if ( false !== strpos( $content, '<' . $tag_name ) ) {
				return true;
			}
		} elseif ( '<s' === $content ) {
			// Ok, we might be coming across the token parser issue. Check the next token.
			$next_ptr      = ( $stackPtr + 1 );
			$rest_tag_name = substr( $tag_name, 1 );

			if ( ! empty( $rest_tag_name )
				&& isset( $this->tokens[ $next_ptr ] )
				&& T_INLINE_HTML === $this->tokens[ $next_ptr ]['code']
				&& 0 === strpos( $this->tokens[ $next_ptr ]['content'], $rest_tag_name )
			) {
				return true;
			}
		}

		return false;
	}

}
