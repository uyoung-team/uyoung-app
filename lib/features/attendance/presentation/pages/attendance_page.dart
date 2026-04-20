import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/attendance_view_model.dart';
import '../../../../shared/services/asset_paths.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceViewModel()..loadBoardData(),
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatelessWidget {
  const _AttendanceView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttendanceViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.images.attendance.background01),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 1. 상단 앱바 (뒤로가기)
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 2. 중앙 캐릭터 및 출석부 영역
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  // 캐릭터 영역
                  Image.asset(
                    AssetPaths.images.attendance.character,
                    width: 200,
                  ),
                  const SizedBox(height: 20),

                  // 출석부 보드
                  _buildAttendanceBoard(vm),
                ],
              ),
            ),

            // 3. 하단 출석하기 버튼
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: vm.hasCheckedToday ? null : () => vm.checkIn(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: vm.hasCheckedToday
                          ? Colors.grey
                          : const Color(0xFF6EA8EB),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      vm.hasCheckedToday ? '출석 완료' : '오늘의 조개 줍기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'memomentKkukkkuk',
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. 로딩 인디케이터
            if (vm.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBoard(AttendanceViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "7일간의 조개 보드",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(7, (index) {
              final day = index + 1;
              final assetPath = vm.boardItemPathForDay(day);
              return Column(
                children: [
                  Image.asset(assetPath, width: 45, height: 45),
                  const SizedBox(height: 4),
                  Text("$day일차", style: const TextStyle(fontSize: 10)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
