import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';

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
      body: Center(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeSuccess) {
              return Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        state.userProfileEntity.profilePictureUrl,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      state.userProfileEntity.name,
                      style: TextStyle(color: Colors.blue, fontSize: 20),
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
