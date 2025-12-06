// Shared lightweight types for node widgets to avoid circular imports.
enum NodeStatus {
  locked,
  inProgress,
  completed,
  legendary,
  jumpAhead, // Node có thể học vượt
}
