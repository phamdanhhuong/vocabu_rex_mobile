import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/profile_header.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/profile_following.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/profile_overview.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          final profile = state.profile;
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.appBarColor,
              elevation: 0,
              title: const Text('Hồ sơ', style: TextStyle(fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(profile: profile),
                    const SizedBox(height: 16),
                    ProfileFollowing(profile: profile),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add),
                      label: const Text('THÊM BẠN BÈ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textWhite,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProfileOverview(profile: profile),
                    const SizedBox(height: 16),
                    const Text('Streak bạn bè', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                    // TODO: Hiển thị streak bạn bè
                  ],
                ),
              ),
            ),
          );
        } else if (state is ProfileError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        return const SizedBox();
      },
    );
  }
}
