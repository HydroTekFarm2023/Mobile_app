import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strawberry_diagnosis/home_screen.dart';
import 'package:strawberry_diagnosis/login_screen_v2.dart';
import 'package:strawberry_diagnosis/scan_page.dart';

class ProfileRelatedScreen extends StatefulWidget {
	const ProfileRelatedScreen({super.key});

	@override
	State<ProfileRelatedScreen> createState() => _ProfileRelatedScreenState();
}

class _ProfileRelatedScreenState extends State<ProfileRelatedScreen> {
	String _userId = 'User ID';
	String _username = '';
	String _email = '';

	@override
	void initState() {
		super.initState();
		_loadCognitoUser();
	}

	Future<void> _loadCognitoUser() async {
		try {
			final authUser = await Amplify.Auth.getCurrentUser();
			String id = authUser.userId;
			String username = authUser.username;
			// fetch attributes (email) if available
			String email = '';
			try {
				final attributes = await Amplify.Auth.fetchUserAttributes();
				for (final attr in attributes) {
					// Compare by the attribute key string to avoid depending on Cognito-specific helpers here
								if (attr.userAttributeKey.key == 'email') {
									email = attr.value;
									break;
								}
				}
			} catch (_) {
				// ignore attribute errors
			}
			if (mounted) {
				setState(() {
					_userId = id.isNotEmpty ? id : 'User ID';
					_username = username;
					_email = email;
				});
			}
		} catch (e) {
			// If Amplify/Auth not configured or user not signed in, keep defaults
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
				backgroundColor: const Color(0xFFF5F9F6),
				appBar: AppBar(
					backgroundColor: Colors.green,
					title: const Text('Profile'),
					centerTitle: true,
					actions: [
						IconButton(
							icon: const Icon(Icons.help_outline),
							onPressed: () {},
						),
					],
					elevation: 0,
				),
								body: Padding(
										padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
										child: LayoutBuilder(
											builder: (context, constraints) {
												return SingleChildScrollView(
													child: ConstrainedBox(
														constraints: BoxConstraints(minHeight: constraints.maxHeight),
														child: IntrinsicHeight(
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.center,
																children: [
																	const SizedBox(height: 16),
																	CircleAvatar(
																		radius: 40,
																		backgroundColor: Colors.grey[300],
																		child: const Icon(Icons.person, size: 48, color: Colors.white),
																	),
																	const SizedBox(height: 12),
																	Text(
																		_username.isNotEmpty ? _username : (_email.isNotEmpty ? _email : _userId),
																		style: const TextStyle(
																			color: Colors.green,
																			fontWeight: FontWeight.bold,
																			fontSize: 16,
																		),
																	),
																	const SizedBox(height: 32),
																	_ProfileMenuButton(label: 'Account Details', icon: Icons.account_circle, onTap: () {
																		Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _PlaceholderScreen(title: 'Account Details')));
																	}),
																	_ProfileMenuButton(label: 'Saved Scans', icon: Icons.bookmark, onTap: () {
																		Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _PlaceholderScreen(title: 'Saved Scans')));
																	}),
																	_ProfileMenuButton(label: 'History', icon: Icons.history, onTap: () {
																		Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _PlaceholderScreen(title: 'History')));
																	}),
																	_ProfileMenuButton(label: 'Settings', icon: Icons.settings, onTap: () {
																		Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _PlaceholderScreen(title: 'Settings')));
																	}),
																	_ProfileMenuButton(label: 'Help & Feedback', icon: Icons.help, onTap: () {
																		Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _PlaceholderScreen(title: 'Help & Feedback')));
																	}),
																	const Spacer(),
																	_ProfileMenuButton(
																		label: 'Log Out',
																		icon: Icons.logout,
																		onTap: () async {
																			try {
																				await Amplify.Auth.signOut();
																			} catch (e) {
																				// ignore sign out errors, proceed to clear local session
																			}
																			final prefs = await SharedPreferences.getInstance();
																			await prefs.clear();
																			if (context.mounted) {
																				Navigator.of(context).pushAndRemoveUntil(
																					MaterialPageRoute(builder: (_) => LoginPageV2()),
																					(route) => false,
																				);
																			}
																		},
																		color: Colors.red,
																	),
																	const SizedBox(height: 16),
																],
															),
														),
													),
												);
											},
										),
								),
						bottomNavigationBar: Container(
							height: 70,
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: const BorderRadius.only(
									topLeft: Radius.circular(24),
									topRight: Radius.circular(24),
								),
								boxShadow: [
									BoxShadow(
										color: Colors.black.withOpacity(0.07),
										blurRadius: 12,
										offset: const Offset(0, -2),
									),
								],
							),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								children: [
									IconButton(
										icon: const Icon(Icons.home, size: 32, color: Colors.green),
										splashRadius: 28,
										onPressed: () {
											Navigator.of(context).pushAndRemoveUntil(
												MaterialPageRoute(builder: (_) => HomeScreen()),
												(route) => false,
											);
										},
									),
									Container(
										decoration: BoxDecoration(
											color: const Color(0xFFE0F5E9),
											borderRadius: BorderRadius.circular(16),
										),
										child: IconButton(
											icon: const Icon(Icons.apps, size: 32, color: Colors.green),
											splashRadius: 28,
											onPressed: () {
												Navigator.of(context).pushAndRemoveUntil(
													MaterialPageRoute(builder: (_) => ScanPage()),
													(route) => false,
												);
											},
										),
									),
									IconButton(
										icon: const Icon(Icons.person, size: 32, color: Colors.green),
										splashRadius: 28,
										onPressed: () {
											// Already on Profile
										},
									),
								],
							),
						),
			);
		}
}

class _ProfileMenuButton extends StatelessWidget {
	final String label;
	final IconData icon;
	final VoidCallback onTap;
	final Color? color;

	const _ProfileMenuButton({
		required this.label,
		required this.icon,
		required this.onTap,
		this.color,
	});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6),
			child: SizedBox(
				width: double.infinity,
				height: 48,
				child: ElevatedButton.icon(
					icon: Icon(icon, color: color ?? Colors.green),
					label: Text(
						label,
						style: TextStyle(
							color: color ?? Colors.green,
							fontWeight: FontWeight.w600,
							fontSize: 16,
						),
					),
					style: ElevatedButton.styleFrom(
						backgroundColor: Colors.white,
						elevation: 0,
						side: BorderSide(color: (color ?? Colors.green).withOpacity(0.2)),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(12),
						),
						padding: const EdgeInsets.symmetric(horizontal: 16),
					),
					onPressed: onTap,
				),
			),
		);
	}
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          '$title Page',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}