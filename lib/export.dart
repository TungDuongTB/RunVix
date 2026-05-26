//package
export 'package:get/get.dart';
export 'package:flutter/cupertino.dart';
export 'package:flutter/gestures.dart';

// Data - Model
export './Data/Model/user_model.dart';
export './Data/Model/workout_model.dart';
export './Data/Model/challenge_model.dart';
export './Data/Model/route_model.dart';

// Data - Repository
export './Data/Repository/authentication_repository.dart';
export './Data/Repository/user_repository.dart';
export './Data/Repository/workout_repository.dart';
export './Data/Repository/calendar_repository.dart';

// Data - Controller
export './Data/Controller/user_controller.dart';
export './Data/Controller/record_controller.dart';
export './Data/Controller/profile_controller.dart';
export './Data/Controller/calendar_controller.dart';

//pages
export './Pages/LoadingScreen.dart';
export './Pages/Authen/LoginScreen.dart';
export './Pages/Authen/SignIn.dart';
export './Pages/Authen/RegisterScreen.dart';
export './reponsive.dart';
export './Pages/Authen/AuthTermsPage.dart';
export 'Pages/Home/Widgets/home/HomeScreen.dart';
export './Pages/Home/Widgets/map/MapScreen.dart';

// Home Widgets
export './Pages/Home/Widgets/home/home_streak_section.dart';
export './Pages/Home/Widgets/home/home_suggested_follows.dart';
export './Pages/Home/Widgets/home/home_suggested_challenges.dart';

// Map Widgets
export './Pages/Home/Widgets/map/map_top_search.dart';
export './Pages/Home/Widgets/map/map_floating_button.dart';
export './Pages/Home/Widgets/map/map_route_card.dart';

// Group Widgets
export './Pages/Home/Widgets/Group/GroupScreen.dart';
export './Pages/Home/Widgets/Group/club_tab_content.dart';

// Record Widgets
export './Pages/Home/Widgets/Record/RecordScreen.dart';
export './Pages/Home/Widgets/Record/record_top_trends_badge.dart';
export './Pages/Home/Widgets/Record/record_floating_buttons.dart';
export './Pages/Home/Widgets/Record/record_stats_card.dart';
export './Pages/Home/Widgets/Record/record_controls.dart';
export './Pages/Home/Widgets/Record/record_advanced_settings.dart';

// Profile Widgets
export './Pages/Home/Widgets/Profile/ProfileScreen.dart';
export './Pages/Home/Widgets/Profile/profile_progress_tab.dart';
export './Pages/Home/Widgets/Profile/profile_activities_tab.dart';
export './Pages/Home/Widgets/Profile/profile_detail_screen.dart';
export './Pages/Home/Widgets/Profile/SettingsScreen.dart';

// Admin Pages
export './Pages/Admin/admin_dashboard_screen.dart';
export './Pages/Admin/admin_users_panel.dart';
export './Pages/Admin/admin_content_panel.dart';
export './Pages/Admin/admin_stats_panel.dart';

//components
export './Component/ColorComponent.dart';
export './Component/ButtonComponent.dart';
export './Component/DividerWithCenter.dart';
export './Component/TextFieldComponent.dart';
export './Component/InputComponent.dart';
export './Component/auth_social_buttons.dart';
export './Component/auth_terms_agreement.dart';
