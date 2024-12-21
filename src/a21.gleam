import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import stdin.{stdin}
import util.{parse}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  stdin()
  |> iterator.map(string.trim)
  |> iterator.map(string.to_graphemes)
  |> iterator.filter(fn(l) { !list.is_empty(l) })
  |> iterator.to_list
}

fn score(l) {
  l |> list.take(3) |> string.join("") |> parse
}

fn num_pad(k) {
  case k {
    "7" -> #(0, 0)
    "8" -> #(1, 0)
    "9" -> #(2, 0)
    "4" -> #(0, 1)
    "5" -> #(1, 1)
    "6" -> #(2, 1)
    "1" -> #(0, 2)
    "2" -> #(1, 2)
    "3" -> #(2, 2)
    "0" -> #(1, 3)
    "A" -> #(2, 3)
    _ -> panic
  }
}

fn direction_pad(k) {
  case k {
    "<" -> #(0, 1)
    "v" -> #(1, 1)
    ">" -> #(2, 1)
    "^" -> #(1, 0)
    "A" -> #(2, 0)
    _ -> panic
  }
}

fn move(from, to, f, r, hv) {
  r(f(from), f(to), [], hv)
}

fn rn(from, to, l, hv) {
  let #(xa, ya) = from
  let #(xb, yb) = to
  let dx = xb - xa
  let dy = yb - ya
  case hv {
    True ->
      case dx, dy {
        0, 0 -> ["A", ..l] |> list.reverse
        x, _ if x < 0 && { xb > 0 || ya < 3 } ->
          rn(#(xb, ya), to, list.flatten([list.repeat("<", -x), l]), hv)
        _, y if y > 0 && { xa > 0 || yb < 3 } ->
          rn(#(xa, yb), to, list.flatten([list.repeat("v", y), l]), hv)
        x, _ if x > 0 ->
          rn(#(xb, ya), to, list.flatten([list.repeat(">", x), l]), hv)
        _, y if y < 0 ->
          rn(#(xa, yb), to, list.flatten([list.repeat("^", -y), l]), hv)
        _, _ -> panic
      }
    False ->
      case dx, dy {
        0, 0 -> ["A", ..l] |> list.reverse
        _, y if y > 0 && { xa > 0 || yb < 3 } ->
          rn(#(xa, yb), to, list.flatten([list.repeat("v", y), l]), hv)
        x, _ if x < 0 && { xb > 0 || ya < 3 } ->
          rn(#(xb, ya), to, list.flatten([list.repeat("<", -x), l]), hv)
        _, y if y < 0 ->
          rn(#(xa, yb), to, list.flatten([list.repeat("^", -y), l]), hv)
        x, _ if x > 0 ->
          rn(#(xb, ya), to, list.flatten([list.repeat(">", x), l]), hv)
        _, _ -> panic
      }
  }
}

fn rd(from, to, l, hv) {
  let #(xa, ya) = from
  let #(xb, yb) = to
  case xb - xa, yb - ya {
    0, 0 -> ["A", ..l] |> list.reverse
    x, _ if x < 0 && { xb > 0 || ya == 1 } ->
      rd(#(xb, ya), to, list.flatten([list.repeat("<", -x), l]), hv)
    _, 1 -> rd(#(xa, ya + 1), to, ["v", ..l], hv)
    _, -1 if xa > 0 -> rd(#(xa, ya - 1), to, ["^", ..l], hv)
    x, _ if x > 0 ->
      rd(#(xb, ya), to, list.flatten([list.repeat(">", x), l]), hv)
    x, _ if x < 0 ->
      rd(#(xb, ya), to, list.flatten([list.repeat("<", -x), l]), hv)
    _, _ -> panic
  }
}

fn directions(l) {
  ["A", ..l]
  |> list.zip(l)
}

fn rec(pairs, n, cache) {
  case n {
    0 -> #(list.length(pairs), cache)
    _ ->
      case pairs {
        [] -> #(0, cache)
        [#(a, b), ..tl] -> {
          case dict.get(cache, #(a, b, n)) {
            Error(_) -> {
              let r = move(a, b, direction_pad, rd, True)
              let #(s, cache) =
                r
                |> directions
                |> rec(n - 1, cache)
              let cache = dict.insert(cache, #(a, b, n), s)
              let #(x, cache) = rec(tl, n, cache)
              #(s + x, cache)
            }
            Ok(s) -> {
              let #(x, cache) = rec(tl, n, cache)
              #(s + x, cache)
            }
          }
        }
      }
  }
}

fn seq(cl, n, hv) {
  cl
  |> directions
  |> list.map(fn(p) { move(pair.first(p), pair.second(p), num_pad, rn, hv) })
  |> list.flatten
  |> directions
  |> rec(n, dict.new())
  |> pair.first
}

fn a() {
  in()
  |> list.map(fn(c) { score(c) * int.min(seq(c, 2, True), seq(c, 2, False)) })
  |> int.sum
  |> int.to_string
}

fn b() {
  in()
  |> list.map(fn(c) { score(c) * int.min(seq(c, 25, True), seq(c, 25, False)) })
  |> int.sum
  |> int.to_string
}
