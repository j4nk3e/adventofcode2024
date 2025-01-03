import gleam/float
import gleam/int
import gleam/list
import gleam/regex
import gleam/result

pub fn unwrap(i) {
  i |> result.lazy_unwrap(fn() { panic })
}

pub fn re(r) {
  regex.compile(r, with: regex.Options(False, False))
  |> unwrap
}

pub fn parse(s) {
  s
  |> int.parse
  |> unwrap
}

pub fn reduce(l, f) {
  l
  |> list.reduce(f)
  |> unwrap
}

pub fn pow(b, p) {
  int.power(b, p |> int.to_float) |> unwrap |> float.round
}

pub fn id(a) {
  a
}
