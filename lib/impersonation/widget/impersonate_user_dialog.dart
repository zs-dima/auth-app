import 'package:auth_app/users/users_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';

void impersonateUserDialog(BuildContext context, {required IUserInfo authUser}) => showDialog(
  context: context,
  useRootNavigator: false, // todo
  builder: (ctx) => AlertDialog(
    shape: const RoundedRectangleBorder(borderRadius: .all(.circular(7.0))),
    contentPadding: EdgeInsets.zero,
    titlePadding: EdgeInsets.zero,
    title: Container(
      height: 40.0,
      alignment: Alignment.center,
      color: const Color(0xFF16171a),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Impersonate ${authUser.name}',
              style: const TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: .bold),
              maxLines: 1,
              overflow: .ellipsis,
              textAlign: .center,
            ),
          ),
          const SizedBox(width: 10.0),
          IconButton(
            onPressed: () => Navigator.of(ctx).pop(),
            icon: const Icon(Icons.close, size: 24.0, color: Colors.white),
          ),
          const SizedBox(width: 10.0),
        ],
      ),
    ),
    content: SizedBox(
      width: MediaQuery.sizeOf(ctx).width - 50.0,
      height: MediaQuery.sizeOf(ctx).height - 50.0,
      child: const ColoredBox(
        color: Color(0xFFfffbff),
        child: Padding(padding: .all(10.0), child: UsersWidget()),
      ),
    ),
  ),
);
