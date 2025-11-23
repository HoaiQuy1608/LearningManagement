String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);

  if (diff.inMinutes < 1) return "vừa xong";
  if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
  if (diff.inHours < 24) return "${diff.inHours} giờ trước";
  if (diff.inDays < 30) return "${diff.inDays} ngày trước";

  return "${dt.day}/${dt.month}/${dt.year}";
}
