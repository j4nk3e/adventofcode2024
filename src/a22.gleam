import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
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
  |> iterator.map(parse)
  |> iterator.to_list
}

fn prune(n) {
  int.bitwise_and(n, 16_777_216 - 1)
}

const shl = int.bitwise_shift_left

const shr = int.bitwise_shift_right

const xor = int.bitwise_exclusive_or

fn next(n) {
  let m = n |> xor(shl(n, 6)) |> prune
  let o = m |> xor(shr(m, 5)) |> prune
  o |> xor(shl(o, 11)) |> prune
}

fn times(n, secret, f) {
  case n {
    0 -> secret
    _ -> times(n - 1, f(secret), f)
  }
}

fn ones(n) {
  n % 10
}

fn a() {
  in()
  |> list.fold(0, fn(acc, s) {
    let r = times(2000, s, next)
    acc + r
  })
  |> int.to_string
}

fn window(n, seq, s, dic) {
  case n {
    0 -> dic
    _ -> {
      let ns = next(s)
      let diff = ones(ns) - ones(s)
      let seq = [diff, ..seq]
      let dic = case seq {
        [a, b, c, d, ..] -> {
          case dict.has_key(dic, #(a, b, c, d)) {
            True -> dic
            False -> dict.insert(dic, #(a, b, c, d), ones(ns))
          }
        }
        _ -> dic
      }
      window(n - 1, seq, ns, dic)
    }
  }
}

fn b() {
  in()
  |> list.fold(dict.new(), fn(acc, s) {
    let d = window(2000, [], s, dict.new())
    dict.combine(acc, d, int.add)
  })
  |> dict.values
  |> list.reduce(int.max)
  |> util.unwrap
  |> int.to_string
}
