import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1612),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E0C),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
        ),
      ),
      body: Center(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeSuccess) {
              return Padding(
                padding: EdgeInsets.only(top: 100.h),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 70.r,
                      backgroundImage: NetworkImage(
                        state.userProfileEntity.profilePictureUrl,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      state.userProfileEntity.fullName,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.sp.clamp(12, 20),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Text("Fail to load profile!!!");
            }
          },
        ),
      ),
    );
  }
}
