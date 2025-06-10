class PaginationEntity {
  final int perPage;
  final String? nextUrl;
  final String? previousUrl;
  const PaginationEntity({
    required this.perPage,
    this.nextUrl,
    this.previousUrl,
  });
}
