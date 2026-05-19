import 'package:uyoung_app/features/home/data/shell_story_model.dart';
const List<ShellStory> shellStories = [
  ShellStory(
    imagePath: 'assets/images/shell_story/sample4.png',
    tag: '칼챔',
    title: '가장 예뻤던 풍경은?',
    date: '2025.11.30 작성',
  ),
  ShellStory(
    imagePath: 'assets/images/memory/japan/tokyo11.png',
    tag: '일본팸 ✈️',
    title: '최근 갔던 여행지 기억나?',
    date: '2025.11.30 작성',
  ),
  ShellStory(
    imagePath: 'assets/images/memory/alcohol/alcohol3.jpeg',
    tag: '술독 🍺',
    title: '그날 왜 그렇게 웃겼을까?',
    date: '2025.11.29 작성',
  ),
];

class ShellFrameContent {
  const ShellFrameContent({
    required this.imagePath,
    required this.title,
    required this.actionText,
    required this.profileImagePath,
    required this.name,
  });

  final String imagePath;
  final String title;
  final String actionText;
  final String profileImagePath;
  final String name;
}

const List<ShellFrameContent> todayShellFrameContents = [
  ShellFrameContent(
    imagePath: 'assets/images/shell_story/shell_story_seaotter.png',
    title: '조개 이야기를 사진으로 채워볼까요?',
    actionText: '사진 추가하기 >',
    profileImagePath: 'assets/images/shell_story/lee_profile.png',
    name: '이윤서',
  ),
  ShellFrameContent(
    imagePath: 'assets/images/shell_story/open_shell_story.png',
    title: '아직 닫혀 있는 조개가 남아있어요',
    actionText: '친구에게 열어달라고 말해 볼까요?',
    profileImagePath: 'assets/images/shell_story/yoon_profile.png',
    name: '윤채림',
  ),
  ShellFrameContent(
    imagePath: 'assets/images/shell_story/open_shell_story.png',
    title: '아직 닫혀 있는 조개가 남아있어요',
    actionText: '친구에게 열어달라고 말해 볼까요?',
    profileImagePath: 'assets/images/shell_story/cho_profile.png',
    name: '조성은',
  ),
  ShellFrameContent(
    imagePath: 'assets/images/shell_story/open_shell_story.png',
    title: '아직 닫혀 있는 조개가 남아있어요',
    actionText: '친구에게 열어달라고 말해 볼까요?',
    profileImagePath: 'assets/images/shell_story/choi_profile.png',
    name: '최보빈',
  ),
];

const List<ShellStory> unfinishedShellStorySeeds = [
  ShellStory(
    imagePath: 'assets/images/shell_story/memory_seaotter2.png',
    tag: '일본팸 ✈️',
    title: '최근 우리가 제일 웃겼던 순간은 언제였을까?',
    date: '',
  ),
  ShellStory(
    imagePath: 'assets/images/shell_story/memory_seaotter1.png',
    tag: '상콩즈 🐼',
    title: '최근 우리가 제일 웃겼던 순간은 언제였을까?',
    date: '',
  ),
  ShellStory(
    imagePath: 'assets/images/shell_story/memory_seaotter3.png',
    tag: '물개 달란트 🐬',
    title: '최근 우리가 제일 웃겼던 순간은 언제였을까?',
    date: '',
  ),
  ShellStory(
    imagePath: 'assets/images/shell_story/sample11.png',
    tag: '칼챔',
    title: '최근 우리가 제일 웃겼던 순간은 언제였을까?',
    date: '',
  ),
  ShellStory(
    imagePath: 'assets/images/memory/couple/couple.png',
    tag: '울 애깅',
    title: '최근 우리가 제일 웃겼던 순간은 언제였을까?',
    date: '',
  ),
  ShellStory(
    imagePath: 'assets/images/memory/alcohol/alcohol1.jpeg',
    tag: '술독 🍺',
    title: '최근 우리가 제일 웃겼던 순간은 언제였을까?',
    date: '',
  ),
  ShellStory(
    imagePath: 'assets/images/memory/europe/prague1.jpeg',
    tag: '유러피안',
    title: '최근 우리가 제일 웃겼던 순간은 언제였을까?',
    date: '',
  ),
];
