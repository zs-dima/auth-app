import 'package:auth_app/users/users_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';

void impersonateUserDialog(BuildContext context, {required IUserInfo authUser}) => showDialog(
  context: context,
  useRootNavigator: false, // todo
  builder: (ctx) => AlertDialog(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7))),
    contentPadding: EdgeInsets.zero,
    titlePadding: EdgeInsets.zero,
    title: Container(
      height: 40,
      alignment: Alignment.center,
      color: const Color(0xFF16171a),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Impersonate ${authUser.name}',
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => Navigator.of(ctx).pop(),
            icon: const Icon(Icons.close, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
    ),
    content: SizedBox(
      width: MediaQuery.sizeOf(ctx).width - 50,
      height: MediaQuery.sizeOf(ctx).height - 50,
      child: const ColoredBox(
        color: Color(0xFFfffbff),
        child: Padding(padding: EdgeInsets.all(10), child: UsersWidget()),
      ),
    ),
  ),
);
