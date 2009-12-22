package lang.util;

enum Quantity<T> {
  Unknown;
  None;
  One(v : T);
  Two(v1 : T, v2 : T);
}