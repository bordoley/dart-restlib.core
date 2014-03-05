part of http;

void _writeContentInfo(final ContentInfo contentInfo, void writeHeaderLine(final String header, final String value)) {
  _writeHeader(CONTENT_ENCODING, contentInfo.encodings, writeHeaderLine);
  _writeHeader(CONTENT_LANGUAGE, contentInfo.languages, writeHeaderLine);
  _writeHeader(CONTENT_LENGTH, contentInfo.length, writeHeaderLine);
  _writeHeader(CONTENT_LOCATION, contentInfo.location, writeHeaderLine);
  _writeHeader(CONTENT_RANGE, contentInfo.range, writeHeaderLine);
  _writeHeader(CONTENT_TYPE, contentInfo.mediaRange, writeHeaderLine);
}

String _contentInfoToString(final ContentInfo contentInfo) {
  final StringBuffer buffer = new StringBuffer();

  _writeContentInfo(contentInfo, _writeHeaderToBuffer(buffer));

  return buffer.toString();
}

ContentInfo _contentInfoWith(
  final ContentInfo delegate,
  final Iterable<ContentEncoding> encodings,
  final Iterable<Language> languages,
  final int length,
  final URI location,
  final MediaRange mediaRange,
  final ContentRange range) {

  if(isNull(encodings) &&
      isNull(languages) &&
      isNull(length) &&
      isNull(length) &&
      isNull(location) &&
      isNull(mediaRange) &&
      isNull(range)) {
    return delegate;
  }

  return new _ContentInfoImpl(
      EMPTY_SEQUENCE.addAll(firstNotNull(encodings, delegate.encodings)),
      EMPTY_SET.addAll(firstNotNull(languages, delegate.languages)),
      computeIfEmpty(new Option(length), () => delegate.length),
      computeIfEmpty(new Option(location), () => delegate.location),
      computeIfEmpty(new Option(mediaRange), () => delegate.mediaRange),
      computeIfEmpty(new Option(range), () => delegate.range));
}

ContentInfo _contentInfoWithout(
  final ContentInfo delegate,
  final bool encodings,
  final bool languages,
  final bool length,
  final bool location,
  final bool mediaRange,
  final bool range) {

  if (encodings && languages && length && location && mediaRange && range) {
    return ContentInfo.NONE;
  }

  return new _ContentInfoImpl(
      !encodings ? EMPTY_SEQUENCE.addAll(delegate.encodings) : EMPTY_SEQUENCE,
      !languages ? EMPTY_SET.addAll(delegate.languages) : EMPTY_SET,
      !length ? delegate.length : Option.NONE,
      !location ? delegate.location : Option.NONE,
      !mediaRange ? delegate.mediaRange : Option.NONE,
      !range ? delegate.range : Option.NONE);
}

abstract class ContentInfo {
  static const ContentInfo NONE = const _ContentInfoNone();

  factory ContentInfo({
    final Iterable<ContentEncoding> encodings,
    final Iterable<Language> languages,
    final int length,
    final URI location,
    final MediaRange mediaRange,
    final ContentRange range}) {

    if (isNull(encodings) &&
        isNull(languages) &&
        isNull(length) &&
        isNull(location) &&
        isNull(mediaRange) &&
        isNull(range)) {
      return ContentInfo.NONE;
    }
    return new _ContentInfoImpl(
        EMPTY_SEQUENCE.addAll(firstNotNull(encodings, EMPTY_LIST)),
        EMPTY_SET.addAll(firstNotNull(languages, EMPTY_LIST)),
        new Option(length),
        new Option(location),
        new Option(mediaRange),
        new Option(range));
  }

  factory ContentInfo.wrapHeaders(final Multimap<Header, String, dynamic> headers) =>
      new _HeadersContentInfoImpl(headers);

  Sequence<ContentEncoding> get encodings;

  FiniteSet<Language> get languages;

  Option<int> get length;

  Option<URI> get location;

  Option<MediaRange> get mediaRange;

  Option<ContentRange> get range;

  String toString();

  ContentInfo with_({
    Iterable<ContentEncoding> encodings,
    Iterable<Language> languages,
    int length,
    URI location,
    MediaRange mediaRange,
    ContentRange range
  });

  ContentInfo without({
    bool encodings: false,
    bool languages: false,
    bool length: false,
    bool location: false,
    bool mediaRange:  false,
    bool range : false
  });
}

abstract class _ContentInfoMixin implements ContentInfo {
  String toString() =>
      _contentInfoToString(this);

  ContentInfo with_({
    final Iterable<ContentEncoding> encodings,
    final Iterable<Language> languages,
    final int length,
    final URI location,
    final MediaRange mediaRange,
    final ContentRange range}) =>
        _contentInfoWith(this, encodings, languages, length, location, mediaRange, range);

  ContentInfo without({
    final bool encodings: false,
    final bool languages: false,
    final bool length: false,
    final bool location: false,
    final bool mediaRange:  false,
    final bool range : false}) =>
        _contentInfoWithout(this, encodings, languages, length, location, mediaRange, range);
}

class _ContentInfoNone implements ContentInfo {
  final ImmutableSequence<ContentEncoding> encodings = EMPTY_SEQUENCE;
  final FiniteSet<Language> languages = EMPTY_SET;
  final Option<int> length = Option.NONE;
  final Option<URI> location = Option.NONE;
  final Option<MediaRange> mediaRange = Option.NONE;
  final Option<ContentRange> range = Option.NONE;

  const _ContentInfoNone();

  String toString() => "";

  ContentInfo with_({
    final Iterable<ContentEncoding> encodings: const [],
    final Iterable<Language> languages : const [],
    final int length,
    final URI location,
    final MediaRange mediaRange,
    final ContentRange range}) =>
        new ContentInfo(
            encodings : encodings,
            languages : languages,
            length : length,
            location : location,
            mediaRange : mediaRange,
            range: range);

  ContentInfo without({
    final bool encodings: false,
    final bool languages: false,
    final bool length: false,
    final bool location: false,
    final bool mediaRange:  false,
    final bool range : false}) =>
        this;
}


class _ContentInfoImpl
    extends Object
    with _ContentInfoMixin
    implements ContentInfo {
  final ImmutableSequence<ContentEncoding> encodings;
  final ImmutableSet<Language> languages;
  final Option<int> length;
  final Option<URI> location;
  final Option<MediaRange> mediaRange;
  final Option<ContentRange> range;

  _ContentInfoImpl(this.encodings, this.languages, this.length, this.location, this.mediaRange, this.range);
}

class _HeadersContentInfoImpl
    extends Object
    with _ContentInfoMixin,
      _Parseable
    implements ContentInfo {
  final Multimap<Header, String, dynamic> _headers;
  ImmutableSequence<ContentEncoding> _encodings;
  ImmutableSet<Language> _languages;
  Option<int> _length;
  Option<URI> _location;
  Option<MediaRange> _mediaRange;
  Option<ContentRange> _range;

  _HeadersContentInfoImpl(this._headers);

  ImmutableSequence<ContentEncoding> get encodings =>
      computeIfNull(_encodings, () {
        _encodings = _parse(_CONTENT_ENCODING_HEADER, CONTENT_ENCODING).map(EMPTY_SEQUENCE.addAll).orElse(EMPTY_SEQUENCE);
        return _encodings;
      });

  ImmutableSet<Language> get languages =>
      computeIfNull(_languages, () {
        _languages = _parse(_CONTENT_LANGUAGE, CONTENT_LANGUAGE).map(EMPTY_SET.addAll).orElse(EMPTY_SET);
        return _languages;
      });

  Option<int> get length =>
      computeIfNull(_length, () {
        _length = _parse(INTEGER, CONTENT_LENGTH);
        return _length;
      });

  Option<URI> get location =>
      computeIfNull(_location, () {
        _location = firstWhere(_headers[CONTENT_LOCATION], (final String uri) => true).flatMap(URI.parser.parse);
        return _location;
      });

  Option<MediaRange> get mediaRange =>
      computeIfNull(_mediaRange, () {
        _mediaRange = _parse(MediaRange.parser, CONTENT_TYPE);
        return _mediaRange;
      });

  Option<ContentRange> get range =>
      computeIfNull(_range, () {
        _range = _parse(ContentRange.parser, CONTENT_RANGE);
        return _range;
      });
}