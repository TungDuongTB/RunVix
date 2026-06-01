import 'package:runvix/export.dart';

class AdminUsersPanel extends StatefulWidget {
  const AdminUsersPanel({super.key});

  @override
  State<AdminUsersPanel> createState() => _AdminUsersPanelState();
}

class _AdminUsersPanelState extends State<AdminUsersPanel> {
  final userController = UserController.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Danh sách người dùng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isSearchExpanded ? (Reponsive.isMobile(context) ? 180 : 300) : 40,
                child: _isSearchExpanded
                    ? TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _isSearchExpanded = false;
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                          ),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: AppColors.buttonColor),
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = true;
                          });
                          Future.delayed(Duration.zero, () => _searchFocusNode.requestFocus());
                        },
                      ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => userController.fetchAllUsers(),
                icon: const Icon(Icons.refresh),
                label: Text(Reponsive.isMobile(context) ? "Tải" : "Tải lại"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Reponsive.isMobile(context) ? 12 : 20, 
                    vertical: 16
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Obx(() {
                if (userController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
                }

                final filteredUsers = userController.allUsers.where((user) {
                  return user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                         user.email.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: Reponsive.isDesktop(context) ? MediaQuery.of(context).size.width - 300 : 1000,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Người dùng')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Vai trò')),
                        DataColumn(label: Text('Địa chỉ')),
                        DataColumn(label: Text('Thao tác')),
                      ],
                      rows: filteredUsers.map((user) {
                        return DataRow(cells: [
                          DataCell(Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePicture),
                                radius: 15,
                              ),
                              const SizedBox(width: 8),
                              Text(user.fullName),
                            ],
                          )),
                          DataCell(Text(user.email)),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.isAdmin ? Colors.red.withOpacity(0.1) : (user.isCoordinator ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.roles.toString().toLowerCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: user.isAdmin ? Colors.red : (user.isCoordinator ? Colors.blue : Colors.green),
                              ),
                            ),
                          )),
                          DataCell(Text(user.address, overflow: TextOverflow.ellipsis)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.blue),
                                onPressed: () => _showUserDetails(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.lock_outline, color: Colors.orange),
                                onPressed: () => _showLockDialog(user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {},
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chi tiết người dùng: ${user.fullName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: CircleAvatar(backgroundImage: NetworkImage(user.profilePicture), radius: 50)),
            const SizedBox(height: 16),
            Text("Username: @${user.username}"),
            Text("Email: ${user.email}"),
            Text("Địa chỉ: ${user.address}"),
            Text("Vai trò: ${user.roles}"),
            const SizedBox(height: 16),
            const Text("Hoạt động gần đây:", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("- Chạy bộ 5km (2 ngày trước)"),
            const Text("- Tham gia thử thách RunVix 2024"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
        ],
      ),
    );
  }

  void _showLockDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Khóa tài khoản"),
        content: Text("Bạn có chắc chắn muốn khóa tài khoản của ${user.fullName} không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              // Xử lý khóa tài khoản
              Navigator.pop(context);
              Get.snackbar("Thành công", "Đã khóa tài khoản ${user.fullName}");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Khóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
