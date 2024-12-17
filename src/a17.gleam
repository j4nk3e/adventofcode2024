import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import stdin.{stdin}
import util.{parse, pow, unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  let in = stdin()

  let assert [a, b, c] =
    in
    |> iterator.take(3)
    |> iterator.map(fn(l) {
      l |> string.trim |> string.split(" ") |> list.last |> unwrap |> parse
    })
    |> iterator.to_list

  let inst =
    in
    |> iterator.to_list
    |> string.join("")
    |> string.trim
    |> string.split(" ")
    |> list.last
    |> unwrap
    |> string.split(",")
    |> list.map(parse)

  #(inst, #(a, b, c))
}

fn op(p, code, literal, reg, out) {
  let #(a, b, c) = reg
  let combo = case literal {
    0 | 1 | 2 | 3 -> literal
    4 -> a
    5 -> b
    6 -> c
    _ -> literal
  }
  let np = p + 2
  case code {
    0 -> #(np, #(a / pow(2, combo), b, c), out)
    1 -> #(np, #(a, int.bitwise_exclusive_or(b, literal), c), out)
    2 -> #(np, #(a, combo % 8, c), out)
    3 if a == 0 -> #(np, #(a, b, c), out)
    3 -> #(literal, #(a, b, c), out)
    4 -> #(np, #(a, int.bitwise_exclusive_or(b, c), c), out)
    5 -> #(np, #(a, b, c), [combo % 8, ..out])
    6 -> #(np, #(a, a / pow(2, combo), c), out)
    7 -> #(np, #(a, b, a / pow(2, combo)), out)
    _ -> panic
  }
}

fn exec(inst, pointer, reg, out) {
  case inst |> dict.get(pointer) {
    Ok(code) -> {
      let literal = dict.get(inst, pointer + 1) |> result.unwrap(0)
      let #(p, reg, out) = op(pointer, code, literal, reg, out)
      exec(inst, p, reg, out)
    }
    Error(_) -> out |> list.reverse
  }
}

fn a() {
  let #(inst, reg) = in()

  inst
  |> to_dict
  |> exec(0, reg, [])
  |> list.map(int.to_string)
  |> string.join(",")
}

fn iter(inst, l, i) {
  let o =
    inst
    |> exec(0, #(i, 0, 0), [])
  match(inst, l, l |> list.reverse, o |> list.reverse, i)
}

fn match(inst, l, r, o, i) {
  case r {
    [rh, ..rt] ->
      case o {
        [oh, ..ot] if rh == oh -> match(inst, l, rt, ot, i)
        [_, ..] -> iter(inst, l, i + 1)
        [] -> iter(inst, l, int.bitwise_shift_left(int.max(i, 1), 3))
      }
    [] -> i
  }
}

fn to_dict(i) {
  i
  |> iterator.from_list
  |> iterator.index
  |> iterator.map(fn(p) { #(pair.second(p), pair.first(p)) })
  |> iterator.to_list
  |> dict.from_list
}

fn b() {
  let #(inst, _r) = in()

  inst
  |> to_dict
  |> iter(inst, 0)
  |> int.to_string
}
