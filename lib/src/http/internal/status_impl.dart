part of restlib.core.http.internal;

class StatusImpl implements Status {
  final int code;
  final String message;
  final String reason;
  final StatusClass statusClass;

  const StatusImpl(this.code, this.message, this.reason, this.statusClass);

  int get hashCode => computeHashCode([code]);

  bool operator==(other) {
    if (identical(this, other)) {
      return true;
    } else if (other is Status) {
      return this.code == other.code;
    } else {
      return false;
    }
  }

  Response toResponse() {
    return new Response(this, entity : this.reason);
  }

  String toString() {
    return "$code $message";
  }
}