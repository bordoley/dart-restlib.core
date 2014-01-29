part of restlib.core.net;

abstract class IRI  {  
  static IRI relativeReference(final IRI base, final IRI relative) =>
      _relativeReference(base, relative, _IRI._builder, IPath.EMPTY);
  
  String get scheme;
  Option<IAuthority> get authority;
  IPath get path;
  String get query;
  String get fragment;
    
  bool get isAbsolute;

  IRI canonicalize();
  
  IRI toIRI();
  URI toURI();
  Uri toUri();
}


