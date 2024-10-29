import './../main.dart';
import 'package:flutter/material.dart';

class UserItem extends StatelessWidget {
  final int id;
  final String firstName;
  final String lastName;
  final String avatarPath;
  final String clubLogo;
  final int userXP;
  final int topPosition;
  final VoidCallback? onTap;

  const UserItem(
      {super.key,
      required this.id,
      required this.firstName,
      required this.lastName,
      required this.avatarPath,
      required this.clubLogo,
      required this.userXP,
      required this.topPosition,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          onTap: onTap,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage('${baseURL}$avatarPath'),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      '$firstName $lastName',
                      style: const TextStyle(
                          fontSize: 13.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text('$userXP XP', style: const TextStyle(fontSize: 12.0)),
                ],
              ),
            ],
          ),
          trailing: Text('# $topPosition',
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.8)
          ),
        ),
      ),
    );
  }
}
