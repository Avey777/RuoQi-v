import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/business/add_tenant_page.dart';
import 'package:ruoqi_platform_pc/business/api_key_page.dart';
import 'package:ruoqi_platform_pc/business/api_token_page.dart';
import 'package:ruoqi_platform_pc/business/audit_dialog_page.dart';
import 'package:ruoqi_platform_pc/business/audit_page.dart';
import 'package:ruoqi_platform_pc/business/business_portal_page.dart';
import 'package:ruoqi_platform_pc/business/change_password_page.dart';
import 'package:ruoqi_platform_pc/business/create_role_page.dart';
import 'package:ruoqi_platform_pc/business/currency_page.dart';
import 'package:ruoqi_platform_pc/business/edit_tenant_page.dart';
import 'package:ruoqi_platform_pc/business/edit_user_page.dart';
import 'package:ruoqi_platform_pc/business/email_config_page.dart';
import 'package:ruoqi_platform_pc/business/general_settings_page.dart';
import 'package:ruoqi_platform_pc/business/invite_user_page.dart';
import 'package:ruoqi_platform_pc/business/language_page.dart';
import 'package:ruoqi_platform_pc/business/log_page.dart';
import 'package:ruoqi_platform_pc/business/login_page.dart';
import 'package:ruoqi_platform_pc/business/menu_manage_page.dart';
import 'package:ruoqi_platform_pc/business/member_list_page.dart';
import 'package:ruoqi_platform_pc/business/permission_page.dart';
import 'package:ruoqi_platform_pc/business/project_list_page.dart';
import 'package:ruoqi_platform_pc/business/project_settings_page.dart';
import 'package:ruoqi_platform_pc/business/region_page.dart';
import 'package:ruoqi_platform_pc/business/role_list_page.dart';
import 'package:ruoqi_platform_pc/business/subscription_page.dart';
import 'package:ruoqi_platform_pc/business/system_manage_page.dart';
import 'package:ruoqi_platform_pc/管理后台/system_settings_dialog.dart';
import 'package:ruoqi_platform_pc/business/team_page.dart';
import 'package:ruoqi_platform_pc/business/team_settings_page.dart';
import 'package:ruoqi_platform_pc/business/tenant_list_page.dart';
import 'package:ruoqi_platform_pc/business/tenant_settings_page.dart';
import 'package:ruoqi_platform_pc/business/timezone_page.dart';
import 'package:ruoqi_platform_pc/business/translation_page.dart';
import 'package:ruoqi_platform_pc/business/user_list_page.dart';
import 'package:ruoqi_platform_pc/business/view_tenant_page.dart';

void main() {
  testWidgets('business pages render without exceptions', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    final pages = <Widget>[
      const LoginPage(),
      const TenantListPage(),
      const AddTenantPage(),
      const EditTenantPage(),
      const ViewTenantPage(),
      const MemberListPage(),
      const UserListPage(),
      const RoleListPage(),
      const AuditPage(),
      const CreateRolePage(),
      const InviteUserPage(),
      const EditUserPage(),
      const ChangePasswordPage(),
      const ApiKeyPage(),
      const TeamPage(),
      const TeamSettingsPage(),
      const SubscriptionPage(),
      LogData.login,
      LogData.operation,
      LogData.payment,
      LogData.verification,
      const GeneralSettingsPage(),
      const CurrencyPage(),
      const LanguagePage(),
      const TranslationPage(),
      const RegionPage(),
      const TimezonePage(),
      const ProjectListPage(),
      const ApiTokenPage(),
      const AuditDialogPage(),
      const SystemManagePage(),
      const PermissionPage(),
      const MenuManagePage(),
      const TenantSettingsPage(),
      const ProjectSettingsPage(),
      const EmailConfigPage(),
      const BusinessPortalPage(),
    ];
    for (final page in pages) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$page should render');
    }
    // 系统设置独立弹窗
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    SystemSettingsDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
    // 顶部导航（还原原型 XX管理后台）
    expect(find.text('XX管理后台'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('用户'), findsOneWidget);
    expect(find.text('日志'), findsOneWidget);
    expect(find.text('退出管理'), findsOneWidget);
    // 一账通是独立体系：不应出现运营中心菜单
    expect(find.text('IAM 运营中心'), findsNothing);
    expect(find.text('业务静态页'), findsNothing);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });
}
