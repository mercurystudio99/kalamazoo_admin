import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/datas/user.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Variables
  final _dataSource = UserDataTableSource();

  @override
  Widget build(BuildContext context) {
    // Set context
    _dataSource.context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Users"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: ScopedModelDescendant<AppModel>(
            builder: (context, child, appModel) {
          return PaginatedDataTable(
            header: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_outlined),
                    contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelText: "Search users",
                    hintText: "Search by: User's name, and id",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: (query) {
                    _dataSource.searchUsers(query.trim());
                  }),
            ),
            columns: [
              const DataColumn(label: Text("Profile Photo")),
              DataColumn(
                  label: const Text("Full name"),
                  onSort: (int columnIndex, bool sortAsc) {
                    // Sort by user fullname
                    _dataSource.sort(USER_FULLNAME, columnIndex, sortAsc);
                  }),
              DataColumn(
                  label: const Text("Gender"),
                  onSort: (int columnIndex, bool sortAsc) {
                    // Sort by gender
                    _dataSource.sort(USER_GENDER, columnIndex, sortAsc);
                  }),
              const DataColumn(label: Text("User ID")),
              // DataColumn(
              //     label: const Text("Status"),
              //     onSort: (int columnIndex, bool sortAsc) {
              //       // Sort by user status
              //       _dataSource.sort(USER_STATUS, columnIndex, sortAsc);
              //     }),
              const DataColumn(label: Text("View")),
            ],
            source: _dataSource,
            sortAscending: appModel.sortAscending,
            sortColumnIndex: appModel.sortColumnIndex,
          );
        }),
      ),
    );
  }
}

class UserDataTableSource extends DataTableSource {
  // Variables
  final List<DocumentSnapshot<Map<String, dynamic>>> _databaseUsers =
      AppModel().users;
  late BuildContext context;
  final List<DocumentSnapshot<Map<String, dynamic>>> _users = [];

  // Constructor
  UserDataTableSource() {
    // Initialize local user list
    _users.addAll(_databaseUsers);
  }

  // Search Users in table
  void searchUsers(String query) {
    // Get all users
    List<DocumentSnapshot<Map<String, dynamic>>> allUsers = [];
    allUsers.addAll(_databaseUsers);

    if (query.isNotEmpty) {
      List<DocumentSnapshot<Map<String, dynamic>>> filteredUsers = [];
      // Loop users to execute search
      for (var item in allUsers) {
        // Search in name
        if (item[USER_FULLNAME]
                .toString()
                .toUpperCase()
                .contains(query.toUpperCase()) ||
            // Search in user id
            item[USER_ID]
                .toString()
                .toUpperCase()
                .contains(query.toUpperCase())) {
          filteredUsers.add(item);
        }
      }
      // Update
      _users.clear();
      _users.addAll(filteredUsers);
      debugPrint('Searching result -> ${_users.length}');
      notifyListeners();
      return;
    } else {
      // Update
      _users.clear();
      _users.addAll(_databaseUsers);
      debugPrint('All users -> ${_users.length}');
      notifyListeners();
    }
  }

  /// Sort User list and update table state
  void sort(String sortField, int columnIndex, bool sortAsc) {
    // Update variables for table settings
    AppModel().updateOnSort(columnIndex, sortAsc);

    _users.sort((userDocA, userDocB) {
      // Variables
      final userA = userDocA[sortField].toString();
      final userB = userDocB[sortField].toString();
      // Returns result
      return sortAsc
          ? userA.compareTo(userB) // Ascending order
          : userB.compareTo(userA); // Descending order
    });
    // Update table state
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    /// Get User object
    final User user = User.fromDocument(_users[index].data()!);

    return DataRow.byIndex(index: index, cells: [
      // User profile photo
      DataCell(
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(user.userProfilePhoto),
        ),
        onTap: () {
          // View user profile
          _viewProfile(user);
        },
      ),
      // User full name
      DataCell(Text(user.userFullname)),
      // User Gender
      DataCell(Text(user.userGender)),
      // User User ID
      DataCell(Text(_cutUserID(user.userId))),
      // User Status
      // DataCell(UserStatus(status: user.userStatus)),
      // Button actions
      DataCell(
        IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey),
          onPressed: () {
            // View user profile
            _viewProfile(user);
          },
        ),
      ),
    ]);
  }

  // Cut the user id to leave space for other fields!
  _cutUserID(String userId) {
    // Check user id length
    if (userId.length < 10) {
      return userId;
    } else {
      final newUserId = userId.substring(0, 10);
      return '$newUserId...';
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _users.length;

  @override
  int get selectedRowCount => 0;

  // View user profile
  void _viewProfile(User user) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
  }
}
