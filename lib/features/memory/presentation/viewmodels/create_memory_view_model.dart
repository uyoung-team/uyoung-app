import 'package:flutter/material.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';

class CreateMemoryViewModel extends ChangeNotifier {
  CreateMemoryViewModel({required MemoryRepository repository})
    : _repository = repository;

  static const int maxTitleLength = 12;
  static const List<String> palette = [
    '#FF6B6B',
    '#FF8E72',
    '#FFB26B',
    '#FFD56B',
    '#F4E76E',
    '#A4D96C',
    '#5FCD8C',
    '#54D2C6',
    '#6FD3FF',
    '#6EA8EB',
    '#7C93FF',
    '#9A7CFF',
    '#B780FF',
    '#E08EFF',
    '#FF94C2',
    '#D7B48C',
    '#B6BDC6',
    '#8B9AA9',
    '#5D6D7E',
    '#2D3A4A',
  ];

  final MemoryRepository _repository;
  final TextEditingController titleController = TextEditingController();
  final List<InviteeUser> _selectedMembers = [];
  String? selectedColor;
  bool isSubmitting = false;

  List<InviteeUser> get selectedMembers => List.unmodifiable(_selectedMembers);
  bool get canProceedToMembers => selectedColor != null;
  bool get canSubmit => _selectedMembers.isNotEmpty;

  void onTitleChanged() {
    notifyListeners();
  }

  void setColor(String color) {
    selectedColor = color;
    notifyListeners();
  }

  void toggleInvitee(InviteeUser user) {
    final index = _selectedMembers.indexWhere((member) => member.id == user.id);
    if (index >= 0) {
      _selectedMembers.removeAt(index);
    } else {
      _selectedMembers.add(user);
    }
    notifyListeners();
  }

  void removeInvitee(String userId) {
    _selectedMembers.removeWhere((member) => member.id == userId);
    notifyListeners();
  }

  bool isSelected(String userId) {
    return _selectedMembers.any((member) => member.id == userId);
  }

  Future<MemoryIslandItem> createIsland() async {
    if (selectedColor == null) {
      throw StateError('기억섬 컬러를 선택해주세요.');
    }
    if (_selectedMembers.isEmpty) {
      throw StateError('초대할 멤버를 1명 이상 선택해주세요.');
    }

    isSubmitting = true;
    notifyListeners();

    try {
      return await _repository.createIsland(
        islandName: _resolveIslandName(),
        color: selectedColor!,
        inviteeIds: _selectedMembers.map((user) => user.id).toList(),
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String _resolveIslandName() {
    final trimmed = titleController.text.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    if (_selectedMembers.length == 1) {
      return '${_selectedMembers.first.nickname}의 기억섬';
    }

    final names = _selectedMembers.take(2).map((user) => user.nickname).join(', ');
    return _selectedMembers.length > 2
        ? '$names 외 ${_selectedMembers.length - 2}명'
        : names;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
