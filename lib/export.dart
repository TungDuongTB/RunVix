//package
export 'package:get/get.dart';
export 'package:flutter/material.dart';
export 'package:flutter/gestures.dart';
export 'package:image_picker/image_picker.dart';
export 'package:geolocator/geolocator.dart';
export 'package:google_maps_flutter/google_maps_flutter.dart';
export 'dart:async';

//firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';

// Data - Model
export './Data/Model/user_model.dart';
export './Data/Model/workout_model.dart';
export './Data/Model/challenge_model.dart';
export './Data/Model/route_model.dart';
export './Data/Model/post_model.dart';
export './Data/Model/comment_model.dart';
export './Data/Model/like_model.dart';
export './Data/Model/report_model.dart';
export './Data/Model/admin_stats_model.dart';

// Data - Repository
export './Data/Repository/authentication_repository.dart';
export './Data/Repository/user_repository.dart';
export './Data/Repository/workout_repository.dart';
export './Data/Repository/calendar_repository.dart';
export './Data/Repository/post_repository.dart';
export './Data/Repository/strava_repository.dart';
export './Data/Repository/admin_repository.dart';

// Data - Controller
export './Data/Controller/user_controller.dart';
export './Data/Controller/record_controller.dart';
export './Data/Controller/profile_controller.dart';
export './Data/Controller/calendar_controller.dart';
export './Data/Controller/navigation_controller.dart';
export './Data/Controller/post_controller.dart';
export './Data/Controller/comment_controller.dart';
export './Data/Controller/manual_activity_controller.dart';
export './Data/Controller/strava_controller.dart';
export './Data/Controller/report_controller.dart';
export './Data/Controller/admin_controller.dart';

// Data - Binding
export './Data/Binding/initial_binding.dart';
export './Data/Binding/map_binding.dart';

//pages
export './Pages/LoadingScreen.dart';
export './Pages/Authen/LoginScreen.dart';
export './Pages/Authen/SignIn.dart';
export './reponsive.dart';
export './Pages/Authen/AuthTermsPage.dart';
export 'Pages/Home/Widgets/home/HomeScreen.dart';
export 'Pages/Home/Widgets/home/comment_screen.dart';
export './Pages/Home/Widgets/map/MapScreen.dart';

// Home Widgets
export './Pages/Home/Widgets/home/home_streak_section.dart';
export './Pages/Home/Widgets/home/home_suggested_follows.dart';
export './Pages/Home/Widgets/home/home_suggested_challenges.dart';

// Map Widgets
export './Pages/Home/Widgets/map/map_top_search.dart';
export './Pages/Home/Widgets/map/map_floating_button.dart';
export './Pages/Home/Widgets/map/map_route_bottom_sheet.dart';
export './Pages/Home/Widgets/map/map_segment_detail_card.dart';
export './Pages/Home/Widgets/map/map_distance_filter_sheet.dart';

// Group Widgets
export './Pages/Home/Widgets/Group/GroupScreen.dart';
export './Pages/Home/Widgets/Group/club_tab_content.dart';

// Record Widgets
export './Pages/Home/Widgets/Record/RecordScreen.dart';
export './Pages/Home/Widgets/Record/record_floating_buttons.dart';
export './Pages/Home/Widgets/Record/record_stats_card.dart';
export './Pages/Home/Widgets/Record/record_controls.dart';
export './Pages/Home/Widgets/Record/record_advanced_settings.dart';

// Profile Widgets
export './Pages/Home/Widgets/Profile/ProfileScreen.dart';
export './Pages/Home/Widgets/Profile/profile_progress_tab.dart';
export './Pages/Home/Widgets/Profile/profile_activities_tab.dart';
export './Pages/Home/Widgets/Profile/profile_detail_screen.dart';
export './Pages/Home/Widgets/Profile/profile_hub_screen.dart';
export './Pages/Home/Widgets/Profile/profile_hub_empty_state.dart';
export './Pages/Home/Widgets/Profile/followers_list_screen.dart';
export './Pages/Home/Widgets/Profile/following_list_screen.dart';
export './Pages/Home/Widgets/Profile/follower_tracking_dashboard.dart';
export './Pages/Home/Widgets/Profile/edit_profile_screen.dart';
export './Pages/Home/Widgets/Profile/create_post_screen.dart';
export './Pages/Home/Widgets/Profile/add_manual_activity_screen.dart';
export './Pages/Home/Widgets/Profile/SettingsScreen.dart';

// Admin Pages
export './Pages/Admin/admin_dashboard_screen.dart';
export './Pages/Admin/admin_users_panel.dart';
export './Pages/Admin/admin_content_panel.dart';
export './Pages/Admin/admin_stats_panel.dart';

//components
export './Component/ColorComponent.dart';
export './Component/GlassCardComponent.dart';
export './Component/ButtonComponent.dart';
export './Component/DividerWithCenter.dart';
export './Component/TextFieldComponent.dart';
export './Component/InputComponent.dart';
export './Component/auth_social_buttons.dart';
export './Component/auth_terms_agreement.dart';
export './Component/action_dialog.dart';
export './Component/FilterComponent.dart';
export './Component/FollowerTrackingWidget.dart';
export '../../../../Component/RouteCardComponent.dart';
export './Component/profile_header_component.dart';
export './Component/profile_stats_row.dart';
export './Component/profile_streak_distance_cards.dart';
export './Component/ProfilePostGridComponent.dart';

// Notification System
export './Data/Model/notification_model.dart';
export './Data/Repository/notification_repository.dart';
export './Data/Controller/notification_controller.dart';
export './Component/notification_bell_widget.dart';
export './Component/notification_dialog.dart';
